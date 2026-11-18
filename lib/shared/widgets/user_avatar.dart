import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// The user's avatar, used in the Home header and the Profile header so
/// both always show the same identity (Round 3):
///
/// - Logged in WITH a profile photo → the real photo
///   (`UserEntity.profilePhotoUrl` from the API) via [CachedNetworkImage].
/// - Logged in WITHOUT a photo (or the photo fails to load) → an
///   initial-letter avatar from the user's name — never a generic
///   person icon, never a broken-image glyph.
/// - Guest / logged out → a login icon.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final bool isGuest;
  final double radius;

  const UserAvatar({
    super.key,
    required this.isGuest,
    this.photoUrl,
    this.name,
    this.radius = 20,
  });

  String get _initial {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return '?';
    // First grapheme-ish unit; runes keep Bengali initials intact.
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  Widget _initialAvatar(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withAlpha(30),
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: radius * 0.95,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return CircleAvatar(
        key: const Key('user_avatar_guest'),
        radius: radius,
        backgroundColor: AppColors.primary.withAlpha(30),
        child: Icon(
          Icons.login_rounded,
          size: radius * 1.05,
          color: AppColors.primaryDark,
        ),
      );
    }

    final url = (photoUrl ?? '').trim();
    if (url.isEmpty) {
      return _initialAvatar(context);
    }

    final size = radius * 2;
    return ClipOval(
      key: const Key('user_avatar_photo'),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // While loading and on ANY load failure, show the initial
        // avatar — the user never sees a broken-image icon.
        placeholder: (_, __) => _initialAvatar(context),
        errorWidget: (_, __, ___) => _initialAvatar(context),
      ),
    );
  }
}
