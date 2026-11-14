import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';

/// Bottom sheet displaying external government and information service tools.
/// Traceability: REQ-040, SCR-001.
void showInfoServicesSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  final services = [
    ('জমির হিসাব ও ক্যালকুলেটর', 'কাঠা, বিঘা, শতক ও একর রূপান্তর', Icons.calculate_outlined, 'https://bhumibd.com/calculator'),
    ('উত্তরাধিকার আইন ও ক্যালকুলেটর', 'মুসলিম ও হিন্দু উত্তরাধিকার হিস্যা নির্ণয়', Icons.family_restroom, 'https://uttoradhikar.org'),
    ('খতিয়ান ও পর্চা অনুসন্ধান', 'অনলাইনে খতিয়ান যাচাই ও সার্টিফাইড কপি আবেদন', Icons.find_in_page_outlined, 'https://eporcha.gov.bd'),
    ('দলিল রেজিস্ট্রি ফি ও খরচ', 'জমি ক্রয়ে সরকারি স্ট্যাম্প ও ট্যাক্স হিসাব', Icons.receipt_long_outlined, 'https://dolil.gov.bd'),
    ('স্যাটেলাইট ও মৌজা ম্যাপ', 'ডিজিটাল ভূমি রেকর্ড ও মৌজা ম্যাপ পরিদর্শন', Icons.satellite_alt_outlined, 'https://land.gov.bd'),
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.infoServicesTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            ...services.map((item) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withAlpha(25),
                  child: Icon(item.$3, color: AppColors.primary, size: 22),
                ),
                title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(item.$2, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening ${item.$1}: ${item.$4}')),
                  );
                },
              );
            }),
          ],
        ),
      );
    },
  );
}
