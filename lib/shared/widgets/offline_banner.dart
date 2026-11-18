import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Slim banner shown at the top of a screen while the device is
/// offline (connectivity_plus). Renders nothing while online, so it is
/// safe to drop at the top of any page body.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _update,
      onError: (_) {}, // plugin unavailable (tests/web) — stay silent
    );
  }

  Future<void> _checkInitial() async {
    try {
      _update(await _connectivity.checkConnectivity());
    } catch (_) {
      // Connectivity plugin unavailable (e.g. in tests) — stay silent.
    }
  }

  void _update(List<ConnectivityResult> results) {
    final offline = results.isEmpty ||
        results.every((r) => r == ConnectivityResult.none);
    if (mounted && offline != _isOffline) {
      setState(() => _isOffline = offline);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      key: const Key('offline_banner'),
      width: double.infinity,
      color: AppColors.warning.withAlpha(28),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                l10n?.offlineBanner ?? 'ইন্টারনেট সংযোগ নেই — আগের তথ্য দেখানো হচ্ছে',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
