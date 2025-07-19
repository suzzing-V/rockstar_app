import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/custom_back_button.dart';
import 'package:rockstar_app/common/text/main_text.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const DefaultAppBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: CustomBackButton(
        onPressed: onBack ?? () => Navigator.pop(context),
      ),
      leadingWidth: 50,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainText(
              label: title,
              fontSize: 25,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
