import 'package:flutter/material.dart';
import 'package:rockstar_app/common/icon/crown_icon.dart';
import 'package:rockstar_app/common/listtile/drawer_list_tile.dart';
import 'package:rockstar_app/common/text/primary_text.dart';

class BandDrawer extends StatelessWidget {
  final String nickname;
  final bool isManager;
  final int bandId;
  final String bandName;

  const BandDrawer({
    super.key,
    required this.nickname,
    required this.isManager,
    required this.bandId,
    required this.bandName,
  });

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
                PrimaryText(label: nickname, fontSize: 25),
                const SizedBox(width: 5),
                if (isManager) const CrownIcon(size: 20),
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
          if (isManager)
            DrawerListTile(
              label: '밴드 이름 수정하기',
              icon: const Icon(Icons.edit),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Placeholder()), // TODO
                );
              },
            ),
          DrawerListTile(
            label: '밴드 나가기',
            icon: const Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Placeholder()), // TODO
              );
            },
          ),
        ],
      ),
    );
  }
}
