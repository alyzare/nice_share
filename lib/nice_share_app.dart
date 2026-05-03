import 'package:flutter/material.dart';
import 'package:nice_share/features/global_notifications/presentation/global_notifications.dart';
import 'package:nice_share/features/splash/splash_page.dart';

class NiceShareApp extends StatefulWidget {
  const NiceShareApp({super.key});

  @override
  State<NiceShareApp> createState() => _NiceShareAppState();
}

class _NiceShareAppState extends State<NiceShareApp> {
  late final _navigatorKey = GlobalNotifications.of(context).navigatorKey;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => GlobalNotifications.of(context).init(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      navigatorKey: _navigatorKey,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: SplashPage(),
    );
  }
}
