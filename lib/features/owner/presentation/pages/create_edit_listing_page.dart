import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/create_listing_params.dart';
import '../bloc/create_listing_bloc.dart';

/// Screen to create or edit an ad listing.
/// Traceability: REQ-025, REQ-026, REQ-028, SCR-012, API-024, API-025, API-038.
class CreateEditListingPage extends StatelessWidget {
  final String? listingId;

  const CreateEditListingPage({super.key, this.listingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateListingBloc>(),
      child: _CreateEditListingForm(listingId: listingId),
    );
  }
}

class _CreateEditListingForm extends StatefulWidget {
  final String? listingId;
  const _CreateEditListingForm({this.listingId});

  @override
  State<_CreateEditListingForm> createState() => _CreateEditListingFormState();
}

class _CreateEditListingFormState extends State<_CreateEditListingForm> {
  final _formKey = GlobalKey<FormState>();

  String _propertyType = 'apartment';
  String _purpose = 'rent';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController(text: 'uttara');
  final _cityController = TextEditingController(text: 'dhaka');
  final _addressController = TextEditingController();
  final _floorController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();

  int _bed = 3;
  int _bath = 2;
  bool _allowDirectContact = true;
  final List<String> _amenities = ['lift', 'generator', 'parking'];
  final List<String> _photos = [
    'https://ghorbd.com/uploads/demo/flat-1-w1200.webp',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _floorController.dispose();
    _unitNumberController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final params = CreateListingParams(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyType: _propertyType,
      purpose: _purpose,
      areaSlug: _areaController.text.trim().toLowerCase(),
      city: _cityController.text.trim().toLowerCase(),
      address: _addressController.text.trim(),
      floor: int.tryParse(_floorController.text.trim()),
      unitNumber: _unitNumberController.text.trim(),
      bed: _bed,
      bath: _bath,
      size: int.tryParse(_sizeController.text.trim()) ?? 0,
      pricePerMonth: int.tryParse(_priceController.text.trim()) ?? 0,
      images: _photos,
      amenities: _amenities,
      contactPhone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      allowDirectContact: _allowDirectContact,
      status: 'pending',
    );

    if (widget.listingId != null) {
      context.read<CreateListingBloc>().add(
            SubmitUpdateListingEvent(
              id: widget.listingId!,
              updateFields: params.toJson(),
            ),
          );
    } else {
      context.read<CreateListingBloc>().add(SubmitCreateListingEvent(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.listingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editListing : l10n.createListingTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<CreateListingBloc, CreateListingState>(
        listener: (context, state) {
          if (state is CreateListingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isUpdate
                      ? l10n.listingUpdatedSuccess
                      : l10n.listingCreatedSuccess,
                ),
                backgroundColor: AppColors.primary,
              ),
            );
            context.pop();
          } else if (state is CreateListingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CreateListingPhotosUploaded) {
            setState(() {
              _photos.addAll(state.urls);
            });
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateListingLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // 1. Purpose selector (Rent / Sale)
                Text(
                  l10n.purpose,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'rent', label: Text(l10n.rent)),
                    ButtonSegment(value: 'sale', label: Text(l10n.sale)),
                  ],
                  selected: {_purpose},
                  onSelectionChanged: (selected) {
                    setState(() => _purpose = selected.first);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Property Type selector
                Text(
                  l10n.filterPropertyType,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _propertyType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: 'apartment', child: Text(l10n.apartment)),
                    DropdownMenuItem(value: 'house', child: Text(l10n.house)),
                    DropdownMenuItem(value: 'room', child: Text(l10n.room)),
                    DropdownMenuItem(value: 'shop', child: Text(l10n.shop)),
                    DropdownMenuItem(value: 'office', child: Text(l10n.office)),
                    DropdownMenuItem(value: 'land', child: Text(l10n.land)),
                    DropdownMenuItem(value: 'hostel', child: Text(l10n.hostel)),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _propertyType = val);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // 3. Title
                AppTextField(
                  controller: _titleController,
                  label: l10n.listingTitle,
                  hint: 'e.g. Uttara Sector 7 — 3 bed family flat',
                  validator: (val) {
                    if (val == null || val.trim().length < 5) {
                      return 'Title must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 4. Description
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.listingDescription,
                  hint: 'e.g. South-facing flat, lift and generator, near metro station.',
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 5. Area and City
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _areaController,
                        label: l10n.area,
                        hint: 'uttara',
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _cityController,
                        label: l10n.city,
                        hint: 'dhaka',
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 6. Address
                AppTextField(
                  controller: _addressController,
                  label: l10n.address,
                  hint: 'e.g. Road 12, Sector 7, Uttara',
                  validator: (val) => val == null || val.isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // 7. Floor & Unit Number
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _floorController,
                        label: l10n.floorNumber,
                        hint: '5',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _unitNumberController,
                        label: l10n.unitNumber,
                        hint: '5B',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 8. Bed & Bath
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.bedrooms, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.remove),
                                onPressed: _bed > 0 ? () => setState(() => _bed--) : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Text('$_bed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              IconButton.outlined(
                                icon: const Icon(Icons.add),
                                onPressed: () => setState(() => _bed++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.bathrooms, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.remove),
                                onPressed: _bath > 0 ? () => setState(() => _bath--) : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Text('$_bath', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              IconButton.outlined(
                                icon: const Icon(Icons.add),
                                onPressed: () => setState(() => _bath++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 9. Size & Price
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _sizeController,
                        label: l10n.size,
                        hint: '1350',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _priceController,
                        label: l10n.priceRent,
                        hint: '25000',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          if (int.tryParse(val.trim()) == null) return 'Must be a number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // 10. Contact Phone & Direct Contact Switch
                AppTextField(
                  controller: _phoneController,
                  label: l10n.contactPhone,
                  hint: '01711000000',
                  keyboardType: TextInputType.phone,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.allowDirectContact),
                  value: _allowDirectContact,
                  onChanged: (val) => setState(() => _allowDirectContact = val),
                ),
                const SizedBox(height: AppSpacing.md),

                // 11. Amenities
                Text(
                  l10n.amenities,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: ['lift', 'generator', 'parking', 'gas', 'cctv'].map((item) {
                    final isSelected = _amenities.contains(item);
                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _amenities.add(item);
                          } else {
                            _amenities.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 12. Photos upload section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.photos,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(l10n.uploadPhotos),
                      onPressed: () {
                        // Mock adding an image URL
                        setState(() {
                          _photos.add(
                            'https://ghorbd.com/uploads/demo/flat-${_photos.length + 1}-w1200.webp',
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_photos.isNotEmpty)
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                              ),
                              child: const Icon(Icons.image, size: 36, color: Colors.grey),
                            ),
                            PositionedDirectional(
                              top: 2,
                              end: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() => _photos.removeAt(index));
                                },
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: AppSpacing.xxl),

                // 13. Submit Button
                AppButton(
                  label: isEditing ? l10n.updateListing : l10n.submitListing,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
