import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Ios_effect/iosTapEffect.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color> colors;
  final double height;
  final double borderRadius;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.colors = const [Color(0xff3bce86), Color(0xff2bd040), Color(0xff09e755)],
    this.height = 50,
    this.borderRadius = 25,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: IosTapEffect(
        onTap: widget.isLoading ? () {} : widget.onTap,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.colors.map((color) {
                // Simply brightens the background slightly when hovered
                return _isHovered && !widget.isLoading
                    ? Color.alphaBlend(Colors.white.withOpacity(0.15), color)
                    : color;
              }).toList(),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Keeps text centered
              widget.isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CupertinoActivityIndicator(
                  radius: 12,
                  color: Colors.white,
                ),
              )
                  : Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

              widget.isLoading
                  ? const SizedBox(width: 42)
                  : Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 21,
                  child: Icon(
                    Icons.arrow_forward,
                    color: widget.colors.first,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}