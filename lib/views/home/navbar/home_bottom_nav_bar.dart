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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.bottomCenter, // ✅ 아래 중앙 고정!
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 내부 요소만큼만 너비
                  children: List.generate(2, (index) {
                    final isSelected = selectedIndex == index;
                    final iconData = index == 0 ? Icons.home : Icons.person;

                    return GestureDetector(
                      onTap: () => onItemSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          iconData,
                          size: 30,
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
        ),
      ),
    );
  }
}
