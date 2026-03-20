import 'package:flutter/material.dart';

class AppPageActionButton extends StatelessWidget {
  const AppPageActionButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(icon),
    );
  }
}
