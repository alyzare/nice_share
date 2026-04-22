import 'package:flutter/material.dart';

class MyNavBar extends StatefulWidget {
  final PageController controller;
  const MyNavBar({super.key, required this.controller});

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  final items = [Icons.home_rounded, Icons.list_alt_rounded];

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
    return Container(
      height: 70,
      margin: EdgeInsets.all(20),
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
              final left = (maxWidth / 2) * (page + 0.5) - 35;
              return Stack(
                children: [
                  Positioned(
                    left: left,
                    child: SizedBox.square(
                      dimension: 70,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: (page - page.round()).abs() * 20 + 5,
                          horizontal: (page - page.round()).abs() * 10 + 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(128),
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
                            if (widget.controller.page?.toInt() != index) {
                              widget.controller.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 150),
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
  State<_AnimatedIconButton> createState() => __AnimatedIconButtonState();
}

class __AnimatedIconButtonState extends State<_AnimatedIconButton> {
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
                ? Theme.of(context).colorScheme.surfaceBright
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
