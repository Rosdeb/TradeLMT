import 'package:flutter/material.dart';

class CircleIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const CircleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<CircleIconButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Material(
          shape: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHovering ? Colors.grey.shade200 : Colors.white,
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}