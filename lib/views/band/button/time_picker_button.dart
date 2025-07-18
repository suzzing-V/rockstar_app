import 'package:flutter/material.dart';

class TimePickerButton extends StatelessWidget {
  final TimeOfDay initialTime;
  final void Function(TimeOfDay pickedTime) onTimePicked;

  const TimePickerButton({
    super.key,
    required this.initialTime,
    required this.onTimePicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
        minimumSize: const Size(100, 40),
        maximumSize: const Size(100, 40),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          initialEntryMode: TimePickerEntryMode.input,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  hourMinuteTextStyle: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  dayPeriodTextStyle: const TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 20,
                  ),
                  helpTextStyle: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  dialTextColor: Theme.of(context).colorScheme.primary,
                  entryModeIconColor: Theme.of(context).colorScheme.primary,
                ),
                textTheme: Theme.of(context).textTheme.apply(
                      fontFamily: 'PixelFont',
                    ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null && picked != initialTime) {
          onTimePicked(picked);
        }
      },
      child: Center(
        child: Text(
          initialTime.format(context),
          style: const TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 23,
          ),
        ),
      ),
    );
  }
}
