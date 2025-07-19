import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/dialog/one_button_dialog.dart';
import 'package:rockstar_app/common/icon/crown_icon.dart';
import 'package:rockstar_app/common/listtile/drawer_list_tile.dart';
import 'package:rockstar_app/common/listtile/warning_drawer_list_tile.dart';
import 'package:rockstar_app/common/text/primary_text.dart';
import 'package:rockstar_app/services/api/band_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:rockstar_app/views/band/pages/select_manager_page.dart';
import 'package:rockstar_app/views/band/pages/update_band_name_page.dart';
import 'package:rockstar_app/views/home/dialogs/one_title_two_button_dialog.dart';
import 'package:rockstar_app/views/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandDrawer extends StatefulWidget {
  final String nickname;
  final bool isManager;
  final int bandId;
  final String bandName;
  final void Function(String? newBandName) onBandNameChanged;
  final void Function(bool isChanged) onManagerChanged;

  const BandDrawer({
    super.key,
    required this.nickname,
    required this.isManager,
    required this.bandId,
    required this.bandName,
    required this.onBandNameChanged,
    required this.onManagerChanged,
  });

  @override
  State<BandDrawer> createState() => _BandDrawerState();
}

class _BandDrawerState extends State<BandDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                PrimaryText(label: widget.nickname, fontSize: 25),
                const SizedBox(width: 5),
                if (widget.isManager) const CrownIcon(size: 20),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Divider(
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.3),
            ),
          ),
          if (widget.isManager)
            DrawerListTile(
              label: '밴드 이름 수정하기',
              icon: Icons.edit,
              onTap: () async {
                String? newBandName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateBandNamePage(bandId: widget.bandId)),
                );
                widget.onBandNameChanged(newBandName);
              },
            ),
          if (widget.isManager)
            DrawerListTile(
              label: '관리자 권한 위임하기',
              icon: Icons.admin_panel_settings,
              onTap: () async {
                final isUpdated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SelectManagerPage(bandId: widget.bandId),
                  ),
                );

                if (isUpdated == true) {
                  widget.onManagerChanged(true);
                  Navigator.pop(context); // drawer 닫기
                }
              },
            ),
          if (widget.isManager)
            WarningDrawerListTile(
              label: '밴드 삭제하기',
              icon: Icons.delete,
              onTap: () {
                // ... (삭제 로직 동일)
              },
            ),
          WarningDrawerListTile(
            label: '밴드 나가기',
            icon: Icons.exit_to_app,
            onTap: () {
              // ... (나가기 로직 동일)
            },
          ),
        ],
      ),
    );
  }
}
