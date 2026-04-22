import 'package:flutter/material.dart';
import 'package:nice_share/features/main/presentation/main_shell.dart';

class NiceShareApp extends StatelessWidget {
  const NiceShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: MainShell(),
    );
  }
}
