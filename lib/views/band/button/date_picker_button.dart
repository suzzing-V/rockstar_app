import 'package:flutter/material.dart';

class DatePickerButton extends StatelessWidget {
  final DateTime initialDate;
  final void Function(DateTime pickedDate) onDatePicked;

  const DatePickerButton({
    super.key,
    required this.initialDate,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
        minimumSize: const Size(155, 40),
        maximumSize: const Size(155, 40),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          locale: const Locale('ko'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                datePickerTheme: DatePickerThemeData(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  headerHeadlineStyle: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  headerHelpStyle: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.7),
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.onPrimaryContainer,
                  onPrimary: Colors.white,
                  onSurface: Theme.of(context).colorScheme.primary,
                ),
                textTheme: Theme.of(context).textTheme.apply(
                      fontFamily: 'PixelFont',
                    ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null && picked != initialDate) {
          onDatePicked(picked);
        }
      },
      child: Center(
        child: Text(
          '${initialDate.year}.${initialDate.month.toString().padLeft(2, '0')}.${initialDate.day.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 23,
          ),
        ),
      ),
    );
  }
}
