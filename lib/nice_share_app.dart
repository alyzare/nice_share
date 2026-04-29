import 'package:flutter/material.dart';
import 'package:nice_share/core/services/server_foreground/server_task_handler.dart';
import 'package:nice_share/features/main/presentation/main_shell.dart';
import 'package:nice_share/features/splash/splash_page.dart';

class NiceShareApp extends StatefulWidget {
  const NiceShareApp({super.key});

  @override
  State<NiceShareApp> createState() => _NiceShareAppState();
}

class _NiceShareAppState extends State<NiceShareApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: SplashPage(),
    );
  }
}
