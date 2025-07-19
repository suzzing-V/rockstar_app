import 'package:flutter/material.dart';

class MenuIconButton extends StatelessWidget {
  final double iconSize;
  final Color? color;

  const MenuIconButton({
    super.key,
    this.iconSize = 30,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      iconSize: iconSize,
      color: color ?? Theme.of(context).colorScheme.primaryFixed,
      onPressed: () {
        Scaffold.of(context).openEndDrawer(); // 부모에 반드시 endDrawer 있어야 함!
      },
    );
  }
}
