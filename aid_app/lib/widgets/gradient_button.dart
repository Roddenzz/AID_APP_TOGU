import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'reusable_explosion_painter.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;

  const GradientButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 56,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _explosionController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _explosionController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null) {
      _tapController.forward();
    }
  }

  void _onTapUp(_) {
    _tapController.reverse();
    if (!widget.isLoading && widget.onPressed != null) {
       widget.onPressed!();
      _explosionController.forward(from: 0.0);
    }
  }
  
  void _onTapCancel() {
     _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = !isDisabled),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: _isHovering 
                      ? AppColors.mediumGray.withOpacity(0.3) 
                      : (isDisabled ? AppColors.darkGray.withOpacity(0.5) : AppColors.mediumGray.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovering 
                        ? AppColors.lightGray.withOpacity(0.8)
                        : (isDisabled ? AppColors.lightGray.withOpacity(0.2) : AppColors.lightGray.withOpacity(0.4)),
                  ),
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.7),
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.label,
                          style: TextStyle(
                            color: isDisabled ? AppColors.lightGray.withOpacity(0.5) : AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              // Particle Explosion Effect
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _explosionController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ExplosionPainter(
                        progress: _explosionController.value,
                        color: AppColors.lightGray, // Using a gray color for the explosion
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
