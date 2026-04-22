import 'package:flutter/material.dart';
import 'package:nice_share/features/home/presentation/home_page.dart';
import 'package:nice_share/features/main/presentation/components/my_nav_bar.dart';
import 'package:nice_share/features/main/presentation/components/pages_stack.dart';
import 'package:nice_share/features/sessions/presentation/sessions_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Nice Share")),
      extendBody: true,
      body: PagesStack(
        pageController: _pageController,
        children: [HomePage(), SessionsPage()],
      ),
      bottomNavigationBar: MyNavBar(controller: _pageController),
    );
  }
}
