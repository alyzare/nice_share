import 'package:flutter/material.dart';

class PagesStack extends StatefulWidget {
  final PageController pageController;
  final List<Widget> children;
  const PagesStack({
    super.key,
    required this.pageController,
    required this.children,
  });

  @override
  State<PagesStack> createState() => _PagesStackState();
}

class _PagesStackState extends State<PagesStack> {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return widget.children[index];
      },
    );
  }
}
