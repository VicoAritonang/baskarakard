import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class DetailKartu extends StatefulWidget {
  final Map<String, dynamic> kartu;

  const DetailKartu({super.key, required this.kartu});

  @override
  State<DetailKartu> createState() => _DetailKartuState();
}

class _DetailKartuState extends State<DetailKartu>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _animationController.reverse();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        _animationController.reverse();
      } else {
        // Ensure we're using voiceNote from Firebase for the audio URL
        final audioUrl =
            widget.kartu['voiceNote'] ?? widget.kartu['audio'] ?? '';

        if (audioUrl.isEmpty) {
          throw Exception('Audio URL tidak tersedia');
        }

        // Set a higher volume
        await _audioPlayer.setVolume(1.0);

        // Log the URL for debugging
        print('Playing audio from: $audioUrl');

        // Start playing with proper Source
        try {
          await _audioPlayer.play(UrlSource(audioUrl));
          _animationController.forward();
        } catch (e) {
          print('Audio player error: $e');
          throw Exception('Gagal memuat audio: $e');
        }
      }
    } catch (e) {
      print('Audio error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar audio: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Coba lagi',
              textColor: Colors.white,
              onPressed: _toggleAudio,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Kartu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF5F5FF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero image with gradient overlay
              Stack(
                children: [
                  Hero(
                    tag: 'kartu-${widget.kartu['id'] ?? "unknown"}',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                widget.kartu['gambar'] ?? ''),
                            fit: BoxFit.cover,
                            onError: (_, __) {
                              // Handle image error silently
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Content section
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                transform: Matrix4.translationValues(0, -20, 0),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Card name centered
                      Text(
                        widget.kartu['nama'] ?? 'Kartu Sastra Jawa',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Pronunciation with better style
                      if (widget.kartu['pelafalan'] != null &&
                          widget.kartu['pelafalan'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.kartu['pelafalan'],
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Audio player with enhanced animation and design
                      if (widget.kartu['voiceNote'] != null ||
                          widget.kartu['audio'] != null) ...[
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Dengarkan Pengucapan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Column(
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _isPlaying
                                                  ? _scaleAnimation.value
                                                  : 1.0,
                                              child: Transform.rotate(
                                                angle: _isPlaying
                                                    ? _rotationAnimation.value
                                                    : 0,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: InkWell(
                                            onTap: _toggleAudio,
                                            customBorder: const CircleBorder(),
                                            child: Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _isPlaying
                                                    ? Icons.stop
                                                    : Icons.play_arrow,
                                                size: 36,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _isPlaying
                                            ? 'Berhenti'
                                            : 'Dengarkan...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Description section with decorative elements
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Keterangan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.kartu['keterangan'] ??
                                    'Tidak ada keterangan tersedia.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerDecoration() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: CornerDecorationPainter(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// Custom painter for the card background pattern
class CardDetailBackgroundPainter extends CustomPainter {
  final Color primaryColor;

  CardDetailBackgroundPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // Draw decorative dots in a grid pattern
    final dotSize = size.width / 50;
    final gap = size.width / 8;

    for (double x = 0.0; x < size.width; x += gap) {
      for (double y = 0.0; y < size.height; y += gap) {
        canvas.drawCircle(
          Offset(x, y),
          dotSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for corner decorations
class CornerDecorationPainter extends CustomPainter {
  final Color color;

  CornerDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw a decorative corner flourish
    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.7, 0);

    canvas.drawPath(path, paint);

    // Add a small circle at the corner
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      size.width * 0.12,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
