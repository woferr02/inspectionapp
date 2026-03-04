import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:health_safety_inspection/services/site_store.dart';
import 'package:health_safety_inspection/theme/app_colors.dart';
import 'package:health_safety_inspection/widgets/primary_button.dart';
import 'package:health_safety_inspection/widgets/secondary_button.dart';

/// Scans a QR code and resolves it to a site for quick check-in / inspection start.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _scanned = true);

    // Try to match a site
    final sites = SiteStore.instance.sites;
    final match = sites.where(
      (s) =>
          s.id == raw ||
          s.name.toLowerCase() == raw.toLowerCase(),
    );

    if (match.isNotEmpty) {
      _showSiteFound(match.first.name, match.first.id);
    } else {
      _showUnknown(raw);
    }
  }

  void _showSiteFound(String siteName, String siteId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.check_circle_outline,
                  size: 32, color: AppColors.success),
            ),
            const SizedBox(height: 12),
            Text(
              'Site found',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              siteName,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(ctx),
                  ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Go to site',
              onPressed: () {
                Navigator.pop(ctx);
                final site = SiteStore.instance.findById(siteId);
                if (site != null) {
                  Navigator.pushNamed(context, '/site-detail',
                      arguments: site);
                }
              },
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              text: 'Start inspection here',
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/templates');
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() => _scanned = false);
    });
  }

  void _showUnknown(String raw) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.help_outline,
                  size: 32, color: AppColors.warning),
            ),
            const SizedBox(height: 12),
            Text(
              'Unknown code',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              raw,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(ctx),
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'This QR code doesn\'t match any registered site.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary(ctx),
                  ),
            ),
            const SizedBox(height: 20),
            SecondaryButton(
              text: 'Scan again',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() => _scanned = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay
          _ScanOverlay(),

          // Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _controller.toggleTorch(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Icon(Icons.flash_on,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 64,
            left: 32,
            right: 32,
            child: Column(
              children: [
                Text(
                  'Scan site QR code',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Point your camera at the QR code on site to check in',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _OverlayPainter(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final cutSize = size.width * 0.65;
    final left = (size.width - cutSize) / 2;
    final top = (size.height - cutSize) / 2.5;

    // Full overlay
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    // Clear rectangle
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final clearRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, cutSize, cutSize),
      const Radius.circular(20),
    );
    canvas.drawRRect(clearRect, clearPaint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final b = 24.0;
    final r = 20.0;

    // Top-left
    canvas.drawArc(
        Rect.fromLTWH(left, top, r * 2, r * 2), 3.14, 0.5 * 3.14, false, bracketPaint);
    canvas.drawLine(Offset(left, top + r), Offset(left, top + b), bracketPaint);
    canvas.drawLine(Offset(left + r, top), Offset(left + b, top), bracketPaint);

    // Top-right
    final right = left + cutSize;
    canvas.drawArc(
        Rect.fromLTWH(right - r * 2, top, r * 2, r * 2), -0.5 * 3.14, 0.5 * 3.14, false, bracketPaint);
    canvas.drawLine(Offset(right, top + r), Offset(right, top + b), bracketPaint);
    canvas.drawLine(Offset(right - r, top), Offset(right - b, top), bracketPaint);

    // Bottom-left
    final bottom = top + cutSize;
    canvas.drawArc(
        Rect.fromLTWH(left, bottom - r * 2, r * 2, r * 2), 0.5 * 3.14, 0.5 * 3.14, false, bracketPaint);
    canvas.drawLine(Offset(left, bottom - r), Offset(left, bottom - b), bracketPaint);
    canvas.drawLine(Offset(left + r, bottom), Offset(left + b, bottom), bracketPaint);

    // Bottom-right
    canvas.drawArc(
        Rect.fromLTWH(right - r * 2, bottom - r * 2, r * 2, r * 2), 0, 0.5 * 3.14, false, bracketPaint);
    canvas.drawLine(Offset(right, bottom - r), Offset(right, bottom - b), bracketPaint);
    canvas.drawLine(Offset(right - r, bottom), Offset(right - b, bottom), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
