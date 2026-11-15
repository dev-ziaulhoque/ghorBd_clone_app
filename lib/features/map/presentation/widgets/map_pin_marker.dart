import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../browse/domain/entities/listing_entity.dart';

/// Premium custom real-estate map marker with property-type icons,
/// purpose badges (Rent/Sale), verified status, and glowing anchor pointers.
class MapPinMarker extends StatefulWidget {
  final ListingEntity listing;
  final bool isSelected;
  final VoidCallback onTap;

  const MapPinMarker({
    super.key,
    required this.listing,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<MapPinMarker> createState() => _MapPinMarkerState();
}

class _MapPinMarkerState extends State<MapPinMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    if (widget.isSelected) {
      _pulseController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant MapPinMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.forward(from: 0.0);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getPropertyIcon(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'house':
      case 'villa':
      case 'duplex':
        return Icons.home_rounded;
      case 'apartment':
      case 'flat':
        return Icons.apartment_rounded;
      case 'office':
      case 'commercial':
      case 'building':
        return Icons.business_rounded;
      case 'land':
      case 'plot':
        return Icons.landscape_rounded;
      case 'shop':
        return Icons.storefront_rounded;
      case 'hostel':
      case 'room':
        return Icons.single_bed_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _getPurposeColor(String purpose, bool isDark) {
    switch (purpose.toLowerCase()) {
      case 'sale':
        return const Color(0xFF2563EB); // Royal Blue for Sale
      case 'land':
        return const Color(0xFFD97706); // Amber for Land
      case 'rent':
      default:
        return AppColors.primary; // Emerald for Rent
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedPrice = AppFormatters.formatBdt(widget.listing.pricePerMonth);
    final purposeColor = _getPurposeColor(widget.listing.purpose, isDark);
    final propertyIcon = _getPropertyIcon(widget.listing.propertyType);

    final isSelected = widget.isSelected;

    // Card colors
    final cardBgColor = isSelected
        ? purposeColor
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    final borderColor = isSelected
        ? Colors.white
        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    final iconBgColor = isSelected
        ? Colors.white.withAlpha(50)
        : (isDark ? Colors.white.withAlpha(20) : purposeColor.withAlpha(25));

    final iconColor = isSelected ? Colors.white : purposeColor;

    return GestureDetector(
      key: ValueKey('map_pin_${widget.listing.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Custom Property Price Card
            Container(
              padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? purposeColor.withAlpha(140)
                        : Colors.black.withAlpha(isDark ? 90 : 30),
                    blurRadius: isSelected ? 12 : 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Property Type Icon Circle
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      propertyIcon,
                      size: 13,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 5),

                  // Verified badge
                  if (widget.listing.verified) ...[
                    Icon(
                      Icons.verified,
                      size: 13,
                      color: isSelected ? Colors.white : AppColors.verifiedBadge,
                    ),
                    const SizedBox(width: 3),
                  ],

                  // Formatted Price Text
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),

                  // Sale / Rent mini dot badge
                  if (widget.listing.purpose == 'sale') ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withAlpha(60)
                            : const Color(0xFF2563EB).withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Sale',
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF2563EB),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 2. Custom Tapered Pointer Needle
            CustomPaint(
              size: const Size(12, 6),
              painter: _PinTrianglePainter(color: cardBgColor),
            ),

            // 3. Precision Anchor Dot with Animated Radial Pulse Wave
            SizedBox(
              width: 20,
              height: 12,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (isSelected)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 8 * _pulseAnimation.value,
                          height: 8 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: purposeColor.withAlpha(
                                ((1.6 - _pulseAnimation.value) * 180).clamp(0, 255).toInt(),
                              ),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 1),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: purposeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: purposeColor.withAlpha(120),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  const _PinTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
