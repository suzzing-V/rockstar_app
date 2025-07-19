import 'package:flutter/material.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';

class WarningDrawerListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const WarningDrawerListTile(
      {super.key, required this.icon, required this.onTap, this.label = ""});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.red,
      ),
      title: HighlightText(
        color: Colors.red,
        label: label,
        fontSize: 18,
      ),
      onTap: onTap,
    );
  }
}
