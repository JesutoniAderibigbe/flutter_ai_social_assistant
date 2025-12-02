import 'package:flutter/material.dart';

class AnimatedGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isLoading;
  
  const AnimatedGradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.gradientColors,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(_isPressed ? 0.3 : 0.5),
                blurRadius: _isPressed ? 15 : 25,
                offset: Offset(0, _isPressed ? 5 : 10),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
