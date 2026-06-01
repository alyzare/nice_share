import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/features/splash/splash_page.dart';

class NiceShareApp extends StatefulWidget {
  const NiceShareApp({super.key});

  @override
  State<NiceShareApp> createState() => _NiceShareAppState();
}

class _NiceShareAppState extends State<NiceShareApp> {
  GlobalKey<NavigatorState> get _navigatorKey => context.read();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: SplashPage(),
    );
  }
}
