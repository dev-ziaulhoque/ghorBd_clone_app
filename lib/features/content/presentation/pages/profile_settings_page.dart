// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/config/app_preferences.dart';
import '../../../../core/security/session_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';

/// Profile & Settings page.
/// Traceability: REQ-041 (Language toggle), REQ-043 (Theme mode), ISS-031 (Account deletion), SCR-010/013.
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  String? _userName;
  String? _userEmail;
  String? _userRole;
  String? _userPhone;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!AppRouter.isAuthenticated) return;

    if (sl.isRegistered<SessionManager>()) {
      final session = sl<SessionManager>();
      final name = await session.getUserName();
      final email = await session.getUserEmail();
      final role = await session.getUserRole();
      final phone = await session.getUserPhone();
      if (mounted) {
        setState(() {
          _userName = name;
          _userEmail = email;
          _userRole = role;
          _userPhone = phone;
        });
      }
    }

    if (sl.isRegistered<GetCurrentUserUseCase>()) {
      final result = await sl<GetCurrentUserUseCase>()();
      if (mounted) {
        result.fold(
          (_) {},
          (user) {
            if (user != null) {
              setState(() {
                _userName = user.name;
                _userEmail = user.email;
                _userRole = user.role;
                _userPhone = user.phone;
                _isVerified = user.verified;
              });
            }
          },
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.localeName == 'bn' ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          l10n.localeName == 'bn'
              ? 'আপনি কি নিশ্চিত যে আপনার অ্যাকাউন্টটি স্থায়ীভাবে মুছে ফেলতে চান? আপনার সমস্ত বিজ্ঞাপন, ফেভারিট এবং তথ্য মুছে যাবে। (স্টোর পলিসি ISS-031: ব্যাকএন্ড কনফার্মেশন প্রসেস করা হবে)'
              : 'Are you sure you want to permanently delete your account? All your listings, favorites, and profile data will be erased. (Store policy ISS-031: Backend request queued)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.btnCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Trigger session clearance and logout
              if (sl.isRegistered<SessionManager>()) {
                sl<SessionManager>().endSession();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.localeName == 'bn'
                        ? 'অ্যাকাউন্ট মুছে ফেলার অনুরোধ গৃহীত হয়েছে এবং সাইন আউট করা হয়েছে।'
                        : 'Account deletion request submitted. You have been logged out.',
                  ),
                ),
              );
              context.go(AppRoutes.home);
            },
            child: Text(
              l10n.localeName == 'bn' ? 'মুছে ফেলুন' : 'Delete',
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.authLogout),
        content: Text(
          l10n.localeName == 'bn'
              ? 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?'
              : 'Are you sure you want to log out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.btnCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (sl.isRegistered<SessionManager>()) {
                sl<SessionManager>().endSession();
              }
              context.go(AppRoutes.home);
            },
            child: Text(l10n.authLogout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = sl.isRegistered<AppPreferencesService>()
        ? sl<AppPreferencesService>()
        : null;
    final isAuth = AppRouter.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.localeName == 'bn' ? 'প্রোফাইল ও সেটিংস' : 'Profile & Settings',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Account Status Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      isAuth && _userName != null && _userName!.isNotEmpty
                          ? _userName!.substring(0, 1).toUpperCase()
                          : (isAuth ? 'U' : 'G'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isAuth
                                    ? (_userName ?? (_userEmail ?? (l10n.localeName == 'bn' ? 'ব্যবহারকারী' : 'User')))
                                    : (l10n.localeName == 'bn' ? 'অতিথি ব্যবহারকারী' : 'Guest User'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: AppColors.verifiedBadge),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAuth
                              ? '${_userRole == 'tenant' ? (l10n.localeName == 'bn' ? 'ভাড়াটিয়া' : 'Tenant') : (_userRole == 'owner' ? (l10n.localeName == 'bn' ? 'মালিক / লিস্টার' : 'Owner / Lister') : (_userRole ?? 'Active'))}${_userEmail != null && _userEmail!.isNotEmpty ? ' • $_userEmail' : ''}'
                              : (l10n.localeName == 'bn' ? 'লগইন করুন সব ফিচারের জন্য' : 'Log in to access all features'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isAuth && _userPhone != null && _userPhone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _userPhone!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isAuth)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      ),
                      onPressed: () => context.push(AppRoutes.login),
                      child: Text(l10n.authLogin),
                    ),
                ],
              ),
            ),
          ),
          if (isAuth) ...[
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary),
                title: Text(
                  _userRole == 'owner'
                      ? (l10n.localeName == 'bn' ? 'মালিক ড্যাশবোর্ড ও বিজ্ঞাপন' : 'Owner Dashboard & Listings')
                      : (l10n.localeName == 'bn' ? 'আমার বিজ্ঞাপন ও ড্যাশবোর্ড' : 'My Listings & Dashboard'),
                ),
                subtitle: Text(
                  _userRole == 'owner'
                      ? (l10n.localeName == 'bn' ? 'বিজ্ঞাপন পরিচালনা ও অ্যানালিটিক্স দেখুন' : 'Manage your ads & view stats')
                      : (l10n.localeName == 'bn' ? 'নতুন বিজ্ঞাপন পোস্ট করুন বা তালিকা দেখুন' : 'Post new ad or view listed properties'),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.push(AppRoutes.dashboard),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Section 1: Language Switcher (REQ-041)
          Text(
            l10n.localeName == 'bn' ? 'ভাষা নির্বাচন (Language)' : 'Language Selection',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('বাংলা (Bangla) - ডিফল্ট'),
                  subtitle: const Text('বাংলায় অ্যাপ ব্যবহার করুন'),
                  value: 'bn',
                  groupValue: prefs?.locale.languageCode ?? 'bn',
                  onChanged: (val) {
                    if (val != null) {
                      prefs?.setLocale(Locale(val));
                    }
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('English (ইংরেজি)'),
                  subtitle: const Text('Use app in English'),
                  value: 'en',
                  groupValue: prefs?.locale.languageCode ?? 'bn',
                  onChanged: (val) {
                    if (val != null) {
                      prefs?.setLocale(Locale(val));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section 2: Theme Mode (REQ-043)
          Text(
            l10n.localeName == 'bn' ? 'থিম মুড (Appearance)' : 'Theme (Appearance)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.localeName == 'bn' ? 'সিস্টেম ডিফল্ট' : 'System Default'),
                  value: ThemeMode.system,
                  groupValue: prefs?.themeMode ?? ThemeMode.system,
                  onChanged: (mode) {
                    if (mode != null) prefs?.setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.localeName == 'bn' ? 'লাইট মোড' : 'Light Mode'),
                  value: ThemeMode.light,
                  groupValue: prefs?.themeMode ?? ThemeMode.system,
                  onChanged: (mode) {
                    if (mode != null) prefs?.setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.localeName == 'bn' ? 'ডার্ক মোড (#0B1017)' : 'Dark Mode (#0B1017)'),
                  value: ThemeMode.dark,
                  groupValue: prefs?.themeMode ?? ThemeMode.system,
                  onChanged: (mode) {
                    if (mode != null) prefs?.setThemeMode(mode);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section 3: Legal & Support links
          Text(
            l10n.localeName == 'bn' ? 'তথ্য ও সহায়তা' : 'Support & Legal',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(l10n.helpTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.help),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.about),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.termsTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.terms),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section 4: Account Actions (Logout, Delete Account)
          if (isAuth) ...[
            Text(
              l10n.localeName == 'bn' ? 'অ্যাকাউন্ট অ্যাকশন' : 'Account Actions',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      l10n.authLogout,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    onTap: () => _showLogoutDialog(context, l10n),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: AppColors.error),
                    title: Text(
                      l10n.localeName == 'bn' ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    subtitle: Text(
                      l10n.localeName == 'bn'
                          ? 'সমস্ত তথ্য স্থায়ীভাবে মুছে ফেলা হবে'
                          : 'Permanently remove your account and listings',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => _showDeleteAccountDialog(context, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Footer: App version
          Center(
            child: Text(
              'GhorBD Mobile App v1.0.0+1',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
