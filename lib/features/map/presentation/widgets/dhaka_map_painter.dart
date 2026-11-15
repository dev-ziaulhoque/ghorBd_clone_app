import 'package:flutter/material.dart';
import '../../../../shared/theme/colors.dart';
import '../utils/dhaka_coordinates.dart';

enum MapThemeStyle {
  modern,
  satelliteNight,
  blueprint,
}

class DhakaMapPainter extends CustomPainter {
  final bool isDark;
  final MapThemeStyle style;

  DhakaMapPainter({
    required this.isDark,
    this.style = MapThemeStyle.modern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Resolve Palette
    final palette = _MapPalette.resolve(isDark, style);

    // 2. Base Landmass
    final bgPaint = Paint()..color = palette.background;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 3. Cadastral Grid Lines & Crosshairs
    _drawGridLines(canvas, size, palette);

    // 4. Urban Parcels / City Blocks
    _drawUrbanBlocks(canvas, palette);

    // 5. Parks and Green Belts
    _drawGreenParks(canvas, palette);

    // 6. Waterways (Rivers, Lakes, Canals)
    _drawWaterways(canvas, palette);

    // 7. Secondary / Connector Streets
    _drawSecondaryStreets(canvas, palette);

    // 8. Major Arterial Highways & Interchanges
    _drawHighways(canvas, palette);

    // 9. Elevated Metro Rail (MRT Line 6)
    _drawMetroRail(canvas, palette);

    // 10. Neighborhood District Labels
    _drawDistrictLabels(canvas, palette);

    // 11. Cartographic Elements (Compass Rose & Scale Bar)
    _drawCartographicOrnaments(canvas, size, palette);
  }

  void _drawGridLines(Canvas canvas, Size size, _MapPalette palette) {
    final gridPaint = Paint()
      ..color = palette.gridLine
      ..strokeWidth = 1.0;

    const step = 140.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Crosshairs at intersections
    final crossPaint = Paint()
      ..color = palette.crosshair
      ..strokeWidth = 1.5;

    for (double x = step; x < size.width; x += step * 2) {
      for (double y = step; y < size.height; y += step * 2) {
        canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), crossPaint);
        canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), crossPaint);
      }
    }
  }

  void _drawUrbanBlocks(Canvas canvas, _MapPalette palette) {
    final blockPaint = Paint()
      ..color = palette.urbanBlock
      ..style = PaintingStyle.fill;

    final blockBorder = Paint()
      ..color = palette.urbanBlockBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Helper to draw residential / commercial block clusters
    void drawCluster(double startX, double startY, int cols, int rows, double w, double h, double gap) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              startX + (c * (w + gap)),
              startY + (r * (h + gap)),
              w,
              h,
            ),
            const Radius.circular(4),
          );
          canvas.drawRRect(rect, blockPaint);
          canvas.drawRRect(rect, blockBorder);
        }
      }
    }

    // Uttara Sectors (Gridded planned township)
    drawCluster(540, 160, 4, 3, 50, 36, 12);
    drawCluster(720, 200, 3, 3, 48, 38, 14);

    // Mirpur Blocks
    drawCluster(360, 680, 3, 4, 46, 34, 12);
    drawCluster(440, 840, 3, 3, 48, 36, 12);

    // Gulshan Commercial & Diplomatic Blocks
    drawCluster(900, 720, 3, 5, 52, 40, 14);

    // Banani Blocks
    drawCluster(780, 740, 2, 4, 48, 38, 12);

    // Bashundhara Residential Area Blocks
    drawCluster(1120, 540, 4, 4, 52, 42, 14);

    // Dhanmondi Numbered Roads (Road 1 - 27)
    drawCluster(520, 1240, 3, 4, 50, 36, 12);
    drawCluster(640, 1260, 2, 3, 46, 34, 12);

    // Mohammadpur & Lalmatia
    drawCluster(400, 1160, 3, 3, 46, 36, 12);

    // Motijheel Commercial Area
    drawCluster(940, 1420, 4, 3, 54, 40, 14);

    // Badda & Rampura
    drawCluster(1100, 880, 3, 4, 48, 36, 12);
  }

  void _drawGreenParks(Canvas canvas, _MapPalette palette) {
    final parkFill = Paint()
      ..color = palette.parkFill
      ..style = PaintingStyle.fill;

    final parkBorder = Paint()
      ..color = palette.parkBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final parks = [
      // Ramna Park & Suhrawardy Udyan
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(740, 1370, 120, 95),
        const Radius.circular(16),
      ),
      // Parliament (Jatiya Sangsad) grounds & Chandrima Udyan
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(600, 1120, 100, 80),
        const Radius.circular(14),
      ),
      // Mirpur Botanical Garden & National Zoo
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(340, 540, 150, 120),
        const Radius.circular(20),
      ),
      // Dhaka Cantonment Green Corridor & Golf Club
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(700, 680, 170, 120),
        const Radius.circular(18),
      ),
      // Dhanmondi Lake Park Promenade
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(580, 1260, 45, 90),
        const Radius.circular(12),
      ),
      // Uttara Sector 7 Park
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(640, 240, 60, 50),
        const Radius.circular(8),
      ),
    ];

    for (final park in parks) {
      canvas.drawRRect(park, parkFill);
      canvas.drawRRect(park, parkBorder);
    }
  }

  void _drawWaterways(Canvas canvas, _MapPalette palette) {
    final riverPaint = Paint()
      ..color = palette.waterway
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final waterFill = Paint()
      ..color = palette.waterway
      ..style = PaintingStyle.fill;

    final shoreLine = Paint()
      ..color = palette.waterwayBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Buriganga River (South)
    final buriganga = Path()
      ..moveTo(60, 1680)
      ..cubicTo(450, 1630, 850, 1670, 1200, 1690)
      ..quadraticBezierTo(1380, 1705, 1580, 1740);
    riverPaint.strokeWidth = 54.0;
    canvas.drawPath(buriganga, riverPaint);

    // Shore accents for Buriganga
    shoreLine.strokeWidth = 1.8;
    canvas.drawPath(buriganga, shoreLine);

    // 2. Turag River (North-West)
    final turag = Path()
      ..moveTo(160, 80)
      ..cubicTo(200, 420, 240, 850, 270, 1180)
      ..cubicTo(290, 1420, 190, 1560, 110, 1670);
    riverPaint.strokeWidth = 36.0;
    canvas.drawPath(turag, riverPaint);
    canvas.drawPath(turag, shoreLine);

    // 3. Hatirjheel Lake (Central iconic butterfly curved lake)
    final hatirjheel = Path()
      ..moveTo(820, 1070)
      ..quadraticBezierTo(880, 1030, 960, 1040)
      ..cubicTo(1020, 1045, 1070, 1070, 1090, 1100)
      ..quadraticBezierTo(1020, 1135, 960, 1130)
      ..cubicTo(900, 1125, 850, 1115, 820, 1070)
      ..close();
    canvas.drawPath(hatirjheel, waterFill);
    canvas.drawPath(hatirjheel, shoreLine);

    // Hatirjheel Overpass Bridges
    final bridgePaint = Paint()
      ..color = palette.highwayCasing
      ..strokeWidth = 4.0;
    canvas.drawLine(const Offset(890, 1035), const Offset(905, 1125), bridgePaint);
    canvas.drawLine(const Offset(970, 1042), const Offset(980, 1130), bridgePaint);
    canvas.drawLine(const Offset(1040, 1055), const Offset(1045, 1120), bridgePaint);

    // 4. Gulshan Lake (North-South channel)
    final gulshanLake = Path()
      ..moveTo(1005, 680)
      ..quadraticBezierTo(1015, 840, 1025, 990);
    riverPaint.strokeWidth = 24.0;
    canvas.drawPath(gulshanLake, riverPaint);
    canvas.drawPath(gulshanLake, shoreLine);

    // 5. Banani Lake
    final bananiLake = Path()
      ..moveTo(855, 710)
      ..quadraticBezierTo(865, 820, 870, 940);
    riverPaint.strokeWidth = 18.0;
    canvas.drawPath(bananiLake, riverPaint);
    canvas.drawPath(bananiLake, shoreLine);

    // 6. Dhanmondi Lake
    final dhanmondiLake = Path()
      ..moveTo(570, 1240)
      ..cubicTo(565, 1290, 610, 1330, 635, 1380);
    riverPaint.strokeWidth = 18.0;
    canvas.drawPath(dhanmondiLake, riverPaint);
    canvas.drawPath(dhanmondiLake, shoreLine);

    // 7. Uttara Lake / Canal
    final uttaraLake = Path()
      ..moveTo(530, 260)
      ..quadraticBezierTo(650, 275, 760, 265);
    riverPaint.strokeWidth = 14.0;
    canvas.drawPath(uttaraLake, riverPaint);
    canvas.drawPath(uttaraLake, shoreLine);
  }

  void _drawSecondaryStreets(Canvas canvas, _MapPalette palette) {
    final streetPaint = Paint()
      ..color = palette.street
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.square;

    // Cross city grids
    final streets = [
      // Uttara sectors horizontal avenues
      Path()..moveTo(520, 180)..lineTo(820, 180),
      Path()..moveTo(520, 220)..lineTo(820, 220),
      Path()..moveTo(520, 310)..lineTo(820, 310),

      // Mirpur cross roads (Mirpur 1, 2, 10, 11, 12, 14)
      Path()..moveTo(320, 740)..lineTo(580, 740),
      Path()..moveTo(340, 820)..lineTo(620, 820),
      Path()..moveTo(350, 920)..lineTo(600, 920),

      // Gulshan avenues (Madani Ave, Kemal Ataturk Ave)
      Path()..moveTo(760, 770)..lineTo(1120, 770),
      Path()..moveTo(760, 860)..lineTo(1100, 860),
      Path()..moveTo(880, 650)..lineTo(1150, 650),

      // Dhanmondi internal streets (Road 2, 4, 8A, 11A, 27)
      Path()..moveTo(480, 1220)..lineTo(720, 1220),
      Path()..moveTo(500, 1290)..lineTo(720, 1290),
      Path()..moveTo(520, 1350)..lineTo(720, 1350),

      // Bashundhara main avenues
      Path()..moveTo(1080, 600)..lineTo(1350, 600),
      Path()..moveTo(1080, 680)..lineTo(1350, 680),

      // Tejgaon industrial avenues
      Path()..moveTo(760, 980)..lineTo(980, 980),
      Path()..moveTo(760, 1040)..lineTo(980, 1040),

      // Motijheel circular avenues
      Path()..moveTo(880, 1450)..lineTo(1160, 1450),
      Path()..moveTo(880, 1510)..lineTo(1160, 1510),
    ];

    for (final s in streets) {
      canvas.drawPath(s, streetPaint);
    }
  }

  void _drawHighways(Canvas canvas, _MapPalette palette) {
    // 1. Airport Road / Dhaka-Mymensingh Highway
    final airportRoad = Path()
      ..moveTo(640, 50)
      ..cubicTo(680, 260, 780, 520, 830, 720)
      ..quadraticBezierTo(850, 890, 840, 960)
      ..quadraticBezierTo(820, 1050, 790, 1120);

    // 2. Mirpur Road
    final mirpurRoad = Path()
      ..moveTo(330, 840)
      ..quadraticBezierTo(410, 970, 470, 1100)
      ..quadraticBezierTo(530, 1200, 640, 1350)
      ..quadraticBezierTo(680, 1450, 710, 1540);

    // 3. Pragati Sarani (Kuril to Rampura)
    final pragatiSarani = Path()
      ..moveTo(950, 520)
      ..quadraticBezierTo(1030, 720, 1050, 900)
      ..quadraticBezierTo(1070, 1080, 1040, 1270);

    // 4. Begum Rokeya Sarani
    final rokeyaSarani = Path()
      ..moveTo(490, 710)
      ..quadraticBezierTo(530, 860, 610, 1020)
      ..quadraticBezierTo(640, 1100, 660, 1150);

    // 5. Bijoy Sarani & Manik Mia Avenue
    final bijoySarani = Path()
      ..moveTo(520, 1190)
      ..lineTo(660, 1150)
      ..quadraticBezierTo(740, 1135, 830, 1120);

    // 6. VIP Road / Kazi Nazrul Islam Avenue (to Shahbagh & Old Dhaka)
    final vipRoad = Path()
      ..moveTo(790, 1120)
      ..lineTo(770, 1260)
      ..quadraticBezierTo(775, 1360, 785, 1420)
      ..quadraticBezierTo(850, 1480, 930, 1520);

    // 7. Hatirjheel Ring Road
    final hatirjheelRing = Path()
      ..moveTo(820, 1070)
      ..quadraticBezierTo(960, 1020, 1090, 1090)
      ..quadraticBezierTo(960, 1150, 820, 1070);

    final highways = [
      airportRoad,
      mirpurRoad,
      pragatiSarani,
      rokeyaSarani,
      bijoySarani,
      vipRoad,
      hatirjheelRing,
    ];

    // Pass 1: Casing (Outer Border)
    final casingPaint = Paint()
      ..color = palette.highwayCasing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final h in highways) {
      canvas.drawPath(h, casingPaint);
    }

    // Pass 2: Core (Surface)
    final corePaint = Paint()
      ..color = palette.highwayCore
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final h in highways) {
      canvas.drawPath(h, corePaint);
    }

    // Kuril Flyover Interchange Loops
    final interchangePaint = Paint()
      ..color = palette.highwayCore
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(const Offset(950, 520), 16, casingPaint..strokeWidth = 6);
    canvas.drawCircle(const Offset(950, 520), 16, interchangePaint);

    // Mohakhali Flyover Interchange
    canvas.drawCircle(const Offset(840, 960), 14, casingPaint..strokeWidth = 6);
    canvas.drawCircle(const Offset(840, 960), 14, interchangePaint);
  }

  void _drawMetroRail(Canvas canvas, _MapPalette palette) {
    // MRT Line 6 Path (Uttara North -> Mirpur 10 -> Agargaon -> Farmgate -> Motijheel)
    final metroPath = Path()
      ..moveTo(610, 200)
      ..lineTo(510, 480)
      ..lineTo(490, 710) // Mirpur 10
      ..quadraticBezierTo(530, 870, 610, 1030) // Agargaon
      ..lineTo(660, 1160) // Bijoy Sarani / Farmgate
      ..quadraticBezierTo(740, 1260, 770, 1370) // Shahbagh
      ..quadraticBezierTo(880, 1460, 1020, 1470); // Motijheel

    // Track base line
    final trackBase = Paint()
      ..color = palette.metroRailBase
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(metroPath, trackBase);

    // Dashed MRT Transit Line
    final trackDash = Paint()
      ..color = palette.metroRailDash
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.butt;

    // Approximate dashed effect via dash metrics
    for (final metric in metroPath.computeMetrics()) {
      double distance = 0.0;
      const dashLength = 8.0;
      const gapLength = 6.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + dashLength);
        canvas.drawPath(extract, trackDash);
        distance += dashLength + gapLength;
      }
    }

    // Metro Stations
    final stationBg = Paint()..color = palette.background;
    final stationRing = Paint()
      ..color = palette.metroRailDash
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const stations = [
      Offset(610, 200), // Uttara North
      Offset(490, 710), // Mirpur 10
      Offset(610, 1030), // Agargaon
      Offset(660, 1160), // Farmgate
      Offset(770, 1370), // Shahbagh
      Offset(1020, 1470), // Motijheel
    ];

    for (final st in stations) {
      canvas.drawCircle(st, 5.0, stationBg);
      canvas.drawCircle(st, 5.0, stationRing);
    }
  }

  void _drawDistrictLabels(Canvas canvas, _MapPalette palette) {
    const districts = [
      _DistrictLabel('উত্তরা • Uttara', 640, 140, isMajor: true),
      _DistrictLabel('মিরপুর • Mirpur', 400, 760, isMajor: true),
      _DistrictLabel('গুলশান • Gulshan', 940, 800, isMajor: true),
      _DistrictLabel('বনানী • Banani', 790, 820, isMajor: true),
      _DistrictLabel('বারিধারা • Baridhara', 1010, 730),
      _DistrictLabel('বসুন্ধরা • Bashundhara', 1180, 600, isMajor: true),
      _DistrictLabel('ধানমন্ডি • Dhanmondi', 540, 1260, isMajor: true),
      _DistrictLabel('মোহাম্মদপুর • Mohammadpur', 400, 1180, isMajor: true),
      _DistrictLabel('বাড্ডা • Badda', 1110, 930),
      _DistrictLabel('তেজগাঁও • Tejgaon', 860, 1010),
      _DistrictLabel('ফার্মগেট • Farmgate', 690, 1180),
      _DistrictLabel('খিলক্ষেত • Khilkhet', 870, 520),
      _DistrictLabel('মতিঝিল • Motijheel', 990, 1440, isMajor: true),
      _DistrictLabel('হাতিরঝিল (Hatirjheel)', 910, 1080, isWater: true),
      _DistrictLabel('বুড়িগঙ্গা নদী (Buriganga)', 750, 1690, isWater: true),
    ];

    for (final d in districts) {
      final textSpan = TextSpan(
        text: d.text,
        style: TextStyle(
          color: d.isWater ? palette.waterwayLabel : (d.isMajor ? palette.labelMajor : palette.labelMinor),
          fontSize: d.isMajor ? 13 : (d.isWater ? 11 : 11),
          fontWeight: d.isMajor ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.6,
          shadows: [
            Shadow(
              color: palette.labelShadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Soft pill badge under major labels
      if (d.isMajor && !d.isWater) {
        final bgRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            d.x - (textPainter.width / 2) - 6,
            d.y - (textPainter.height / 2) - 3,
            textPainter.width + 12,
            textPainter.height + 6,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(bgRect, Paint()..color = palette.labelBgPill);
        canvas.drawRRect(
          bgRect,
          Paint()
            ..color = palette.gridLine
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }

      textPainter.paint(
        canvas,
        Offset(d.x - (textPainter.width / 2), d.y - (textPainter.height / 2)),
      );
    }
  }

  void _drawCartographicOrnaments(Canvas canvas, Size size, _MapPalette palette) {
    // 1. Compass Rose (Top Right)
    final compassCenter = Offset(size.width - 90, 90);
    final compassRing = Paint()
      ..color = palette.crosshair
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(compassCenter, 24, compassRing);

    // North Needle
    final northPath = Path()
      ..moveTo(compassCenter.dx, compassCenter.dy - 22)
      ..lineTo(compassCenter.dx + 6, compassCenter.dy)
      ..lineTo(compassCenter.dx, compassCenter.dy - 5)
      ..lineTo(compassCenter.dx - 6, compassCenter.dy)
      ..close();
    canvas.drawPath(northPath, Paint()..color = AppColors.primary);

    // South Needle
    final southPath = Path()
      ..moveTo(compassCenter.dx, compassCenter.dy + 22)
      ..lineTo(compassCenter.dx + 6, compassCenter.dy)
      ..lineTo(compassCenter.dx, compassCenter.dy + 5)
      ..lineTo(compassCenter.dx - 6, compassCenter.dy)
      ..close();
    canvas.drawPath(southPath, Paint()..color = palette.crosshair);

    final nSpan = TextSpan(
      text: 'N',
      style: TextStyle(
        color: palette.labelMajor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    final nPainter = TextPainter(text: nSpan, textDirection: TextDirection.ltr)..layout();
    nPainter.paint(canvas, Offset(compassCenter.dx - (nPainter.width / 2), compassCenter.dy - 38));

    // 2. Scale Bar (Bottom Left)
    const scaleOrigin = Offset(70, DhakaCoordinates.canvasHeight - 60);
    const scaleWidth = 120.0;
    final scalePaint = Paint()
      ..color = palette.labelMajor
      ..strokeWidth = 2.0;

    canvas.drawLine(scaleOrigin, Offset(scaleOrigin.dx + scaleWidth, scaleOrigin.dy), scalePaint);
    canvas.drawLine(scaleOrigin, Offset(scaleOrigin.dx, scaleOrigin.dy - 6), scalePaint);
    canvas.drawLine(
      Offset(scaleOrigin.dx + (scaleWidth / 2), scaleOrigin.dy),
      Offset(scaleOrigin.dx + (scaleWidth / 2), scaleOrigin.dy - 4),
      scalePaint,
    );
    canvas.drawLine(
      Offset(scaleOrigin.dx + scaleWidth, scaleOrigin.dy),
      Offset(scaleOrigin.dx + scaleWidth, scaleOrigin.dy - 6),
      scalePaint,
    );

    final scaleSpan = TextSpan(
      text: '2 km (Dhaka Cartography)',
      style: TextStyle(
        color: palette.labelMinor,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    final scaleTextPainter = TextPainter(text: scaleSpan, textDirection: TextDirection.ltr)..layout();
    scaleTextPainter.paint(canvas, Offset(scaleOrigin.dx, scaleOrigin.dy - 18));
  }

  @override
  bool shouldRepaint(covariant DhakaMapPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.style != style;
  }
}

class _DistrictLabel {
  final String text;
  final double x;
  final double y;
  final bool isMajor;
  final bool isWater;

  const _DistrictLabel(
    this.text,
    this.x,
    this.y, {
    this.isMajor = false,
    this.isWater = false,
  });
}

class _MapPalette {
  final Color background;
  final Color gridLine;
  final Color crosshair;
  final Color urbanBlock;
  final Color urbanBlockBorder;
  final Color parkFill;
  final Color parkBorder;
  final Color waterway;
  final Color waterwayBorder;
  final Color waterwayLabel;
  final Color street;
  final Color highwayCasing;
  final Color highwayCore;
  final Color metroRailBase;
  final Color metroRailDash;
  final Color labelMajor;
  final Color labelMinor;
  final Color labelBgPill;
  final Color labelShadow;

  const _MapPalette({
    required this.background,
    required this.gridLine,
    required this.crosshair,
    required this.urbanBlock,
    required this.urbanBlockBorder,
    required this.parkFill,
    required this.parkBorder,
    required this.waterway,
    required this.waterwayBorder,
    required this.waterwayLabel,
    required this.street,
    required this.highwayCasing,
    required this.highwayCore,
    required this.metroRailBase,
    required this.metroRailDash,
    required this.labelMajor,
    required this.labelMinor,
    required this.labelBgPill,
    required this.labelShadow,
  });

  factory _MapPalette.resolve(bool isDark, MapThemeStyle style) {
    if (style == MapThemeStyle.blueprint) {
      return const _MapPalette(
        background: Color(0xFF0F2038),
        gridLine: Color(0xFF1E3A60),
        crosshair: Color(0xFF38BDF8),
        urbanBlock: Color(0xFF162D4E),
        urbanBlockBorder: Color(0xFF224A7A),
        parkFill: Color(0xFF123438),
        parkBorder: Color(0xFF2DD4BF),
        waterway: Color(0xFF0C274D),
        waterwayBorder: Color(0xFF38BDF8),
        waterwayLabel: Color(0xFF7DD3FC),
        street: Color(0xFF1E3E66),
        highwayCasing: Color(0xFF0A192C),
        highwayCore: Color(0xFF38BDF8),
        metroRailBase: Color(0xFF071424),
        metroRailDash: Color(0xFFFBBF24),
        labelMajor: Color(0xFFF0F9FF),
        labelMinor: Color(0xFF93C5FD),
        labelBgPill: Color(0xCC0F2038),
        labelShadow: Colors.black54,
      );
    }

    if (style == MapThemeStyle.satelliteNight || isDark) {
      return const _MapPalette(
        background: Color(0xFF121822),
        gridLine: Color(0xFF1D2636),
        crosshair: Color(0xFF37475F),
        urbanBlock: Color(0xFF1A2230),
        urbanBlockBorder: Color(0xFF253146),
        parkFill: Color(0xFF12281D),
        parkBorder: Color(0xFF1A452F),
        waterway: Color(0xFF0E253F),
        waterwayBorder: Color(0xFF1D426D),
        waterwayLabel: Color(0xFF60A5FA),
        street: Color(0xFF222C3E),
        highwayCasing: Color(0xFF2C394F),
        highwayCore: Color(0xFFF59E0B),
        metroRailBase: Color(0xFF161E2C),
        metroRailDash: Color(0xFF10B981),
        labelMajor: Color(0xFFF8FAFC),
        labelMinor: Color(0xFF94A3B8),
        labelBgPill: Color(0xE6131B26),
        labelShadow: Colors.black87,
      );
    }

    // Modern Light
    return const _MapPalette(
      background: Color(0xFFF1F5F9),
      gridLine: Color(0xFFE2E8F0),
      crosshair: Color(0xFFCBD5E1),
      urbanBlock: Color(0xFFFFFFFF),
      urbanBlockBorder: Color(0xFFE2E8F0),
      parkFill: Color(0xFFDCFCE7),
      parkBorder: Color(0xFFBBF7D0),
      waterway: Color(0xFFBAE6FD),
      waterwayBorder: Color(0xFF7DD3FC),
      waterwayLabel: Color(0xFF0284C7),
      street: Color(0xFFE2E8F0),
      highwayCasing: Color(0xFFCBD5E1),
      highwayCore: Color(0xFFF59E0B),
      metroRailBase: Color(0xFFE2E8F0),
      metroRailDash: Color(0xFF059669),
      labelMajor: Color(0xFF0F172A),
      labelMinor: Color(0xFF475569),
      labelBgPill: Color(0xF2FFFFFF),
      labelShadow: Color(0x33000000),
    );
  }
}
