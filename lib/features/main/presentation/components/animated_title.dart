import 'package:flutter/material.dart';

class AnimatedTitle extends StatefulWidget {
  final List<String> titles;
  final PageController controller;
  const AnimatedTitle({
    super.key,
    required this.titles,
    required this.controller,
  });

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> {
  double get page {
    try {
      return widget.controller.page ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  void initState() {
    widget.controller.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.titles.length, (index) {
        final opacity = (1 - (page - index).abs() * 2).clamp(0.0, 1.0);
        return Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: opacity,
            child: Text(
              widget.titles[index],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }

  void _onScroll() => setState(() {});
}
