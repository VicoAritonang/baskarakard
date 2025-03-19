import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appw/screens/detail_kartu.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  bool isProcessing = false;
  bool isTorchOn = false;
  bool _permissionDenied = false;
  bool _hasError = false;
  String _errorMessage = '';

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Minta izin kamera dan mulai scanner
    if (!kIsWeb) {
      _requestCameraPermission();
    } else {
      // Di web, langsung inisialisasi tanpa permintaan izin khusus
      _initializeCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else {
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    try {
      if (kIsWeb) {
        // Khusus untuk web, gunakan format yang lebih sederhana
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          formats: const [BarcodeFormat.qrCode], // Hanya scan QR Code di web
        );
      } else {
        // Untuk mobile
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        );
      }

      // Tambahkan delay untuk memastikan widget telah dibuat
      await Future.delayed(const Duration(milliseconds: 500));
      await _controller?.start();
    } catch (e) {
      debugPrint('Error starting camera: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Gagal menginisialisasi kamera: ${e.toString()}';
      });
    }
  }

  MobileScannerController get controller {
    if (_controller == null) {
      _initializeCamera();
    }
    return _controller!;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String qrCode) async {
    // Prevent multiple scans while processing
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Attempt to parse the QR code as an integer
      final id = int.tryParse(qrCode);

      if (id == null) {
        _showErrorMessage('QR Code tidak valid. Kode harus berupa angka.');
        return;
      }

      // Query Firestore for the card with the matching ID
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('kartu_sastra')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _showErrorMessage('Kartu dengan ID $id tidak ditemukan.');
        return;
      }

      final kartuData = snapshot.docs.first.data() as Map<String, dynamic>;

      if (!mounted) return;

      // Navigate to the detail card page with a custom page transition
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DetailKartu(kartu: kartuData),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      _showErrorMessage('Terjadi kesalahan: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: Colors.black,
          ),

          // Permission denied screen
          if (_permissionDenied) _buildPermissionDeniedUI(primaryColor),

          // Error screen
          if (_hasError) _buildErrorUI(primaryColor),

          // Scanner
          if (!_permissionDenied && !_hasError)
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes[0].rawValue != null) {
                  _processQRCode(barcodes[0].rawValue!);
                }
              },
            ),

          // Scan animation
          if (!_permissionDenied && !_hasError)
            Center(
              child: AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Scanning box
                      Container(
                        width: size.width * 0.8,
                        height: size.width * 0.8,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryColor,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      // Scanning line
                      Positioned(
                        top: (size.width * 0.8) * _scanAnimation.value -
                            (size.width * 0.4),
                        child: Container(
                          width: size.width * 0.7,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0),
                                primaryColor,
                                primaryColor.withOpacity(0),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Corner decorations
                      _buildCorner(
                          position: 1, color: primaryColor), // Top left
                      _buildCorner(
                          position: 2, color: primaryColor), // Top right
                      _buildCorner(
                          position: 3, color: primaryColor), // Bottom left
                      _buildCorner(
                          position: 4, color: primaryColor), // Bottom right
                    ],
                  );
                },
              ),
            ),

          // Overlay gradient at the top
          Container(
            height: MediaQuery.of(context).padding.top + 80,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Processing overlay
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Memproses...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Back button and title
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Instructions & Buttons
          if (!_permissionDenied && !_hasError)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Instructions
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Arahkan kamera ke QR Code kartu sastra',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Restart camera button
                    ElevatedButton.icon(
                      onPressed: () {
                        _controller?.dispose();
                        _controller = null;
                        _initializeCamera();
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Aktifkan Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Torch button (hide on web)
                        if (!kIsWeb)
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.toggleTorch();
                              setState(() {
                                isTorchOn = !isTorchOn;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTorchOn
                                  ? primaryColor
                                  : Colors.white.withOpacity(0.8),
                              foregroundColor:
                                  isTorchOn ? Colors.white : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: Icon(
                              isTorchOn ? Icons.flash_off : Icons.flash_on,
                            ),
                            label: const Text(
                              'Flashlight',
                            ),
                          ),
                        if (!kIsWeb) const SizedBox(width: 16),

                        // Switch camera button
                        ElevatedButton.icon(
                          onPressed: () => controller.switchCamera(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.cameraswitch),
                          label: const Text(
                            'Camera',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorUI(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'Gagal Memulai Kamera',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Terjadi kesalahan saat memulai kamera. Ini bisa disebabkan oleh browser Anda atau izin kamera. Pada browser Chrome, pastikan Anda telah mengizinkan akses kamera.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (kIsWeb)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Catatan: Pemindai QR code bekerja lebih baik pada aplikasi mobile. Jika memungkinkan, gunakan aplikasi di Android atau iOS.',
                  style: TextStyle(
                    color: Colors.amber,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _controller?.dispose();
                _controller = null;
                _initializeCamera();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedUI(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            const Text(
              'Izin Kamera Dibutuhkan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi memerlukan akses kamera untuk dapat memindai QR Code. Harap berikan izin kamera untuk melanjutkan.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestCameraPermission,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Berikan Izin Kamera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({required int position, required Color color}) {
    // Position: 1 = top left, 2 = top right, 3 = bottom left, 4 = bottom right
    final double size = MediaQuery.of(context).size.width * 0.1;

    // Determine position
    late AlignmentDirectional alignment;
    late Widget child;

    switch (position) {
      case 1:
        alignment = AlignmentDirectional.topStart;
        child = _buildCornerPath(size: size, color: color);
        break;
      case 2:
        alignment = AlignmentDirectional.topEnd;
        child = Transform.rotate(
          angle: math.pi / 2,
          child: _buildCornerPath(size: size, color: color),
        );
        break;
      case 3:
        alignment = AlignmentDirectional.bottomStart;
        child = Transform.rotate(
          angle: -math.pi / 2,
          child: _buildCornerPath(size: size, color: color),
        );
        break;
      case 4:
        alignment = AlignmentDirectional.bottomEnd;
        child = Transform.rotate(
          angle: math.pi,
          child: _buildCornerPath(size: size, color: color),
        );
        break;
      default:
        alignment = AlignmentDirectional.topStart;
        child = _buildCornerPath(size: size, color: color);
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.all(size * 0.2),
        width: size,
        height: size,
        child: child,
      ),
    );
  }

  Widget _buildCornerPath({required double size, required Color color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: CornerPainter(color: color),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Color color;

  CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.4, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
