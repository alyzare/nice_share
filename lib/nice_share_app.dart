import 'package:flutter/material.dart';
import 'package:nice_share/features/home/presentation/home_page.dart';

class NiceShareApp extends StatelessWidget {
  const NiceShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage(
    ));
  }
}
