import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/custom_text_button.dart';
import 'package:rockstar_app/services/api/schedule_service.dart';
import 'package:rockstar_app/services/api/user_service.dart';
import 'package:rockstar_app/views/auth/start_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleDeleteDialog extends StatelessWidget {
  final int scheduleId;

  const ScheduleDeleteDialog({
    super.key,
    required this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 5, right: 8),
      title: Text(
        '일정을 삭제하시겠습니까?',
        style: TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 18,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomTextButton(
              label: '확인',
              onPressed: () async {
                final response =
                    await ScheduleService.deleteSchedule(scheduleId);

                if (response.statusCode == 204 || response.statusCode == 404) {
                  Navigator.of(context).pop(true); // ← 여기에서 true 반환
                } else if (response.statusCode == 401) {
                  final reissue = await UserService.reissueToken();
                  if (reissue.statusCode == 200) {
                    final retry =
                        await ScheduleService.deleteSchedule(scheduleId);
                    if (retry.statusCode == 200 || retry.statusCode == 404) {
                      Navigator.of(context).pop(true);
                    }
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => AnimatedStartPage()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            CustomTextButton(
              label: '취소',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ],
    );
  }
}
