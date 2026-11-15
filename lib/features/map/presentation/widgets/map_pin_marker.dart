import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../browse/domain/entities/listing_entity.dart';

class MapPinMarker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedPrice = AppFormatters.formatBdt(listing.pricePerMonth);

    final bgColor = isSelected
        ? AppColors.primary
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    final borderColor = isSelected
        ? Colors.white
        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    final iconColor = isSelected
        ? Colors.white
        : (listing.verified ? AppColors.verifiedBadge : AppColors.primary);

    return GestureDetector(
      key: ValueKey('map_pin_${listing.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedScale(
        scale: isSelected ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Price Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withAlpha(120)
                        : Colors.black.withAlpha(isDark ? 80 : 30),
                    blurRadius: isSelected ? 10 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    listing.verified ? Icons.verified : Icons.location_on,
                    size: 14,
                    color: iconColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Downward Pin Pointer
            CustomPaint(
              size: const Size(12, 6),
              painter: _PinTrianglePainter(color: bgColor),
            ),

            // 3. Anchor Pulse Indicator (When selected)
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(150),
                      blurRadius: 6,
                      spreadRadius: 2,
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
