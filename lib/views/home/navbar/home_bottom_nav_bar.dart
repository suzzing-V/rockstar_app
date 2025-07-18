import 'dart:ui';
import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 110, right: 110, bottom: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 65,
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(2, (index) {
                final isSelected = selectedIndex == index;
                final iconData = index == 0 ? Icons.home : Icons.person;

                return GestureDetector(
                  onTap: () => onItemSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      iconData,
                      size: 31,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
