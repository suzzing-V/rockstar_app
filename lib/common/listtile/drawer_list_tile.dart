import 'package:flutter/material.dart';
import 'package:rockstar_app/common/text/highlight_text.dart';

class DrawerListTile extends StatelessWidget {
  final Icon icon;
  final String label;
  final VoidCallback onTap;

  const DrawerListTile(
      {super.key, required this.icon, required this.onTap, this.label = ""});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.edit),
      title: HighlightText(
        label: label,
        fontSize: 18,
      ),
      onTap: onTap,
    );
  }
}
