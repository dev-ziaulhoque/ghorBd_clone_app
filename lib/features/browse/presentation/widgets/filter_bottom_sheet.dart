import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/facets_entity.dart';

/// Modal bottom sheet for filtering listings adhering to SCR-003 and REQ-008.
class FilterBottomSheet extends StatefulWidget {
  final ListingFilterParams currentParams;
  final ValueChanged<ListingFilterParams> onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentParams,
    required this.onApply,
  });

  static Future<void> show({
    required BuildContext context,
    required ListingFilterParams currentParams,
    required ValueChanged<ListingFilterParams> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        currentParams: currentParams,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _purpose;
  late String? _propertyType;
  late int? _bedrooms;
  late bool? _verified;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _purpose = widget.currentParams.purpose;
    _propertyType = widget.currentParams.propertyType;
    _bedrooms = widget.currentParams.bedrooms;
    _verified = widget.currentParams.verified;
    _minPriceController = TextEditingController(
      text: widget.currentParams.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentParams.maxPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _purpose = null;
      _propertyType = null;
      _bedrooms = null;
      _verified = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    final minP = int.tryParse(_minPriceController.text.trim());
    final maxP = int.tryParse(_maxPriceController.text.trim());

    final updated = widget.currentParams.copyWith(
      purpose: _purpose,
      clearPurpose: _purpose == null,
      propertyType: _propertyType,
      clearPropertyType: _propertyType == null,
      bedrooms: _bedrooms,
      clearBedrooms: _bedrooms == null,
      verified: _verified,
      clearVerified: _verified == null,
      minPrice: minP,
      maxPrice: maxP,
      clearPrice: minP == null && maxP == null,
      page: 1,
    );

    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Title & Reset Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filterTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(l10n.filterReset),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),

            // 1. Purpose: Rent / Sale
            Text(
              l10n.filterPurpose,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                AppFilterChip(
                  label: l10n.all,
                  isSelected: _purpose == null,
                  onSelected: (_) => setState(() => _purpose = null),
                ),
                AppFilterChip(
                  label: l10n.rent,
                  isSelected: _purpose == 'rent',
                  onSelected: (_) => setState(() => _purpose = 'rent'),
                ),
                AppFilterChip(
                  label: l10n.sale,
                  isSelected: _purpose == 'sale',
                  onSelected: (_) => setState(() => _purpose = 'sale'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Property Type
            Text(
              l10n.filterPropertyType,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                AppFilterChip(
                  label: l10n.all,
                  isSelected: _propertyType == null,
                  onSelected: (_) => setState(() => _propertyType = null),
                ),
                AppFilterChip(
                  label: l10n.apartment,
                  isSelected: _propertyType == 'apartment',
                  onSelected: (_) => setState(() => _propertyType = 'apartment'),
                ),
                AppFilterChip(
                  label: l10n.house,
                  isSelected: _propertyType == 'house',
                  onSelected: (_) => setState(() => _propertyType = 'house'),
                ),
                AppFilterChip(
                  label: l10n.room,
                  isSelected: _propertyType == 'room',
                  onSelected: (_) => setState(() => _propertyType = 'room'),
                ),
                AppFilterChip(
                  label: l10n.shop,
                  isSelected: _propertyType == 'shop',
                  onSelected: (_) => setState(() => _propertyType = 'shop'),
                ),
                AppFilterChip(
                  label: l10n.office,
                  isSelected: _propertyType == 'office',
                  onSelected: (_) => setState(() => _propertyType = 'office'),
                ),
                AppFilterChip(
                  label: l10n.land,
                  isSelected: _propertyType == 'land',
                  onSelected: (_) => setState(() => _propertyType = 'land'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. Bedrooms (only if not land/shop/office)
            if (_propertyType != 'land' &&
                _propertyType != 'shop' &&
                _propertyType != 'office') ...[
              Text(
                l10n.filterBedrooms,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  AppFilterChip(
                    label: l10n.all,
                    isSelected: _bedrooms == null,
                    onSelected: (_) => setState(() => _bedrooms = null),
                  ),
                  for (final b in [1, 2, 3, 4])
                    AppFilterChip(
                      label: l10n.bedroomsCount(b),
                      isSelected: _bedrooms == b,
                      onSelected: (_) => setState(() => _bedrooms = b),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 4. Price Range
            Text(
              l10n.filterPriceRange,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Min ৳',
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Max ৳',
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 5. Verified Only Switch
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.filterVerifiedOnly,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: _verified == true,
              activeTrackColor: AppColors.verifiedBadge,
              onChanged: (val) => setState(() => _verified = val ? true : null),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Apply Button
            AppButton(
              label: l10n.filterApply,
              onPressed: _apply,
            ),
          ],
        ),
      ),
    );
  }
}
