import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single cached response payload plus when it was fetched.
class CacheEntry {
  /// Decoded JSON payload (List / Map / scalar) as produced by `jsonDecode`.
  final dynamic data;

  /// When the payload was fetched from the network.
  final DateTime fetchedAt;

  const CacheEntry({required this.data, required this.fetchedAt});

  /// True when the entry is older than [ttl] and should be revalidated
  /// (stale-while-revalidate: the stale value is still served instantly).
  bool isStale(Duration ttl) => DateTime.now().difference(fetchedAt) > ttl;
}

/// Response cache for slow-changing API data (areas, guides, static
/// pages, pricing).
///
/// Two layers:
///  * an in-memory map (instant, per app session), and
///  * [SharedPreferences] persistence (survives restarts), stored as
///    `ghorbd_cache_<key>` JSON envelopes `{t: epochMillis, d: payload}`.
///
/// TTL policy (Round 2): areas 12 h, pricing 12 h, static content
/// (guides / static pages) 24 h — these change rarely, and the backend
/// TTFB is ~1.2–1.9 s, so serving them from cache removes whole
/// round-trips from the critical path.
///
/// The cache is a [ChangeNotifier]: every [write] notifies listeners and
/// records [lastChangedKey], which lets HomeBloc implement true
/// stale-while-revalidate — render the stale value instantly, refresh in
/// the background, and re-emit when the fresh value lands in the cache.
class ResponseCache extends ChangeNotifier {
  static const String _prefix = 'ghorbd_cache_';

  /// Areas change rarely (new neighbourhoods are added occasionally).
  static const Duration areasTtl = Duration(hours: 12);

  /// Pricing plans change rarely and are not time-critical.
  static const Duration pricingTtl = Duration(hours: 12);

  /// Guides and static pages (about / terms / help…) are editorial
  /// content; a day-old copy is indistinguishable for users.
  static const Duration staticContentTtl = Duration(hours: 24);

  final SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memory = {};

  /// Key of the most recent [write] (used by listeners to react only to
  /// the data they display).
  String? lastChangedKey;

  ResponseCache([this._prefs]);

  /// Reads [key] from memory first, then from persistent storage.
  /// Returns null when nothing is cached or the stored value is corrupt.
  Future<CacheEntry?> read(String key) async {
    final mem = _memory[key];
    if (mem != null) return mem;

    final prefs = _prefs;
    if (prefs == null) return null;
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final entry = CacheEntry(
        data: decoded['d'],
        fetchedAt:
            DateTime.fromMillisecondsSinceEpoch(decoded['t'] as int? ?? 0),
      );
      _memory[key] = entry;
      return entry;
    } catch (_) {
      // Corrupt / legacy payload — drop it and treat as a cache miss.
      await prefs.remove('$_prefix$key');
      return null;
    }
  }

  /// Synchronous memory-only read (null when not in memory).
  CacheEntry? readMemory(String key) => _memory[key];

  /// Stores [data] (must be JSON-encodable) under [key] in both layers
  /// and notifies listeners.
  Future<void> write(String key, dynamic data) async {
    final entry = CacheEntry(data: data, fetchedAt: DateTime.now());
    _memory[key] = entry;
    final prefs = _prefs;
    if (prefs != null) {
      try {
        await prefs.setString(
          '$_prefix$key',
          jsonEncode({'t': entry.fetchedAt.millisecondsSinceEpoch, 'd': data}),
        );
      } catch (_) {
        // Non-serialisable payload: memory copy still serves this session.
      }
    }
    lastChangedKey = key;
    notifyListeners();
  }

  /// Removes one key from both layers (no notification).
  Future<void> remove(String key) async {
    _memory.remove(key);
    await _prefs?.remove('$_prefix$key');
  }

  /// Clears the whole cache (both layers).
  Future<void> clear() async {
    _memory.clear();
    final prefs = _prefs;
    if (prefs != null) {
      for (final k in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
        await prefs.remove(k);
      }
    }
  }
}
