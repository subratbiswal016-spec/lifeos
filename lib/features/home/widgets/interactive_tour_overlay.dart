import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/widgets/glass_container.dart';

class TourTarget {
  final GlobalKey key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TourTarget({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class InteractiveTourOverlay extends StatefulWidget {
  final List<TourTarget> targets;
  final VoidCallback onComplete;

  const InteractiveTourOverlay({
    super.key,
    required this.targets,
    required this.onComplete,
  });

  @override
  State<InteractiveTourOverlay> createState() => _InteractiveTourOverlayState();
}

class _InteractiveTourOverlayState extends State<InteractiveTourOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  
  // Animation for smooth spotlight movement (glide effect)
  late AnimationController _glideController;
  late Animation<Offset> _positionAnimation;
  late Animation<Size> _sizeAnimation;
  
  // Animation for the pulsing spotlight ring
  late AnimationController _pulseController;

  // Animation for card fade in/out
  late AnimationController _cardController;
  late Animation<double> _cardOpacity;
  late Animation<double> _cardScale;

  Offset _currentPosition = Offset.zero;
  Size _currentSize = Size.zero;

  Offset _lastPosition = Offset.zero;
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();

    _glideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTarget(animate: false);
    });
  }

  @override
  void dispose() {
    _glideController.dispose();
    _pulseController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _updateTarget({bool animate = true}) {
    if (widget.targets.isEmpty || _currentStep >= widget.targets.length) return;

    final target = widget.targets[_currentStep];
    final context = target.key.currentContext;

    if (context == null) {
      // Key not mounted yet, wait one frame and try again
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateTarget(animate: animate));
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final newPosition = renderBox.localToGlobal(Offset.zero);
    final newSize = renderBox.size;

    _lastPosition = _currentPosition == Offset.zero ? newPosition : _currentPosition;
    _lastSize = _currentSize == Size.zero ? newSize : _currentSize;

    if (animate) {
      _cardController.reverse().then((_) {
        setState(() {
          _positionAnimation = Tween<Offset>(
            begin: _lastPosition,
            end: newPosition,
          ).animate(CurvedAnimation(parent: _glideController, curve: Curves.easeInOutCubic));

          _sizeAnimation = Tween<Size>(
            begin: _lastSize,
            end: newSize,
          ).animate(CurvedAnimation(parent: _glideController, curve: Curves.easeInOutCubic));
        });

        _glideController.forward(from: 0.0).then((_) {
          _currentPosition = newPosition;
          _currentSize = newSize;
          _cardController.forward(from: 0.0);
        });
      });
    } else {
      setState(() {
        _currentPosition = newPosition;
        _currentSize = newSize;
        
        _positionAnimation = AlwaysStoppedAnimation<Offset>(newPosition);
        _sizeAnimation = AlwaysStoppedAnimation<Size>(newSize);
      });
      _cardController.forward(from: 0.0);
    }
  }

  void _nextStep() {
    if (_currentStep < widget.targets.length - 1) {
      setState(() {
        _currentStep++;
      });
      _updateTarget();
    } else {
      _cardController.reverse().then((_) {
        widget.onComplete();
      });
    }
  }

  void _skipTour() {
    _cardController.reverse().then((_) {
      widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.targets.isEmpty || _currentPosition == Offset.zero) {
      return const SizedBox.shrink();
    }

    final target = widget.targets[_currentStep];
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Custom Spotlight Backdrop Painter
        AnimatedBuilder(
          animation: _glideController,
          builder: (context, child) {
            final pos = _positionAnimation.value;
            final sz = _sizeAnimation.value;

            return CustomPaint(
              size: size,
              painter: SpotlightPainter(
                targetPosition: pos,
                targetSize: sz,
              ),
            );
          },
        ),

        // Glowing Pulsing ring around the spotlight
        AnimatedBuilder(
          animation: Listenable.merge([_glideController, _pulseController]),
          builder: (context, child) {
            final pos = _positionAnimation.value;
            final sz = _sizeAnimation.value;
            final pulseVal = _pulseController.value;

            return CustomPaint(
              size: size,
              painter: PulseRingPainter(
                targetPosition: pos,
                targetSize: sz,
                pulseValue: pulseVal,
                glowColor: target.color,
              ),
            );
          },
        ),

        // Non-interactive transparent area over the target to prevent clicks elsewhere
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {}, // Blocks taps on screen behind
          ),
        ),

        // Description Card containing the tutorial text
        AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            // Position the card dynamically based on highlighted target dy position
            final cardHeight = 200.0;
            final cardWidth = size.width - 48.0;
            
            final pos = _positionAnimation.value;
            final sz = _sizeAnimation.value;

            double cardTop = pos.dy - cardHeight - 20;
            // If the highlighted item is too close to the top, show the card below it instead
            if (cardTop < 50) {
              cardTop = pos.dy + sz.height + 20;
            }

            return Positioned(
              top: cardTop,
              left: 24,
              width: cardWidth,
              child: Opacity(
                opacity: _cardOpacity.value,
                child: Transform.scale(
                  scale: _cardScale.value,
                  child: Material(
                    color: Colors.transparent, // Ensures proper typography inheritance and removes yellow double underlines
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                      borderRadius: 24,
                      blur: 25,
                      color: Colors.black.withOpacity(0.45), // Premium dark glassmorphism blend
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: target.color.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: target.color.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  target.icon,
                                  color: target.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  target.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            target.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Step ${_currentStep + 1} of ${widget.targets.length}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: _skipTour,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Premium button with solid background color
                                  GestureDetector(
                                    onTap: _nextStep,
                                    child: Container(
                                      constraints: const BoxConstraints(minWidth: 100),
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: target.color,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: target.color.withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _currentStep == widget.targets.length - 1
                                            ? 'Got it!'
                                            : 'Next',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SpotlightPainter extends CustomPainter {
  final Offset targetPosition;
  final Size targetSize;

  SpotlightPainter({
    required this.targetPosition,
    required this.targetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.78);

    // Full screen background
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Rounded rectangle spotlight hole
    const double padding = 6.0;
    final holeRect = Rect.fromLTWH(
      targetPosition.dx - padding,
      targetPosition.dy - padding,
      targetSize.width + (padding * 2),
      targetSize.height + (padding * 2),
    );

    // Rounded rectangle path
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(16)));

    // Combined path with difference to cut a hole in background
    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(finalPath, paint);

    // Draw solid glowing border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(holeRect, const Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetPosition != targetPosition ||
        oldDelegate.targetSize != targetSize;
  }
}

class PulseRingPainter extends CustomPainter {
  final Offset targetPosition;
  final Size targetSize;
  final double pulseValue;
  final Color glowColor;

  PulseRingPainter({
    required this.targetPosition,
    required this.targetSize,
    required this.pulseValue,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double basePadding = 6.0;
    final double padding = basePadding + (pulseValue * 12.0);

    final holeRect = Rect.fromLTWH(
      targetPosition.dx - padding,
      targetPosition.dy - padding,
      targetSize.width + (padding * 2),
      targetSize.height + (padding * 2),
    );

    final opacity = (1.0 - pulseValue) * 0.6;
    final ringPaint = Paint()
      ..color = glowColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(holeRect, Radius.circular(16 + (pulseValue * 6))),
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PulseRingPainter oldDelegate) {
    return oldDelegate.targetPosition != targetPosition ||
        oldDelegate.targetSize != targetSize ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.glowColor != glowColor;
  }
}
