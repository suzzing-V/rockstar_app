import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/custom_back_button.dart';
import 'package:rockstar_app/common/buttons/menu_icon_button.dart';
import 'package:rockstar_app/common/text/main_text.dart';

class BandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String bandName;

  const BandAppBar({super.key, required this.bandName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: const CustomBackButton(),
      leadingWidth: 50,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Flexible(
              child: MainText(
                label: bandName,
                fontSize: 25,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: Builder(
            builder: (context) => MenuIconButton(),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
