import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/components/responsive_modal.dart';
import 'package:nice_share/features/main/presentation/components/exit_modal.dart';

class MyNavBar extends StatefulWidget {
  final PageController controller;

  const MyNavBar({super.key, required this.controller});

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  final items = [
    Icons.home_rounded,
    Icons.list_alt_rounded,
    Icons.history_rounded,
  ];

  late final ValueNotifier<double> _pageNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_pageListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_pageListener);
    _pageNotifier.dispose();
    super.dispose();
  }

  void _pageListener() {
    _pageNotifier.value = widget.controller.page ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          SizedBox(
            width: (width - 50).clamp(200, 500),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _pageNotifier,
                      builder: (context, page, _) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final maxWidth = constraints.maxWidth;
                            final left = (maxWidth / 3) * (page + 0.5) - 35;
                            return Stack(
                              children: [
                                Positioned(
                                  left: left,
                                  child: SizedBox.square(
                                    dimension: 70,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical:
                                            (page - page.round()).abs() * 30 +
                                            5,
                                        horizontal:
                                            (page - page.round()).abs() * 15 +
                                            5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withAlpha(64),
                                        borderRadius: BorderRadius.circular(
                                          75 - (page - page.round()).abs() * 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Row(
                                    mainAxisAlignment: .spaceAround,
                                    children: List.generate(
                                      items.length,
                                      (index) => _AnimatedIconButton(
                                        isSelected: (page - index).abs() < 0.2,
                                        onTap: () {
                                          if (widget.controller.page?.toInt() !=
                                              index) {
                                            widget.controller.animateToPage(
                                              index,
                                              duration: const Duration(
                                                milliseconds: 150,
                                              ),
                                              curve: Curves.easeIn,
                                            );
                                          }
                                        },
                                        icon: items[index],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                _OffButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _AnimatedIconButton({
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 250),
          tween: ColorTween(
            begin: Colors.grey,
            end: widget.isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          builder: (context, color, child) {
            return Icon(widget.icon, color: color);
          },
        ),
      ),
    );
  }
}

class _OffButton extends StatelessWidget {
  const _OffButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final bool exitResult =
            await context.showResponsiveModal(child: ExitModal()) ?? false;

        if (!exitResult) return;

        await FlutterForegroundTask.stopService();
        exit(0);
      },
      icon: Icon(Icons.power_settings_new_rounded),
    );
  }
}
