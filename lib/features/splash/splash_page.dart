import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';
import 'package:nice_share/core/services/server_foreground/server_task_handler.dart';
import 'package:nice_share/features/main/presentation/main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _init());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        try {
          await FlutterForegroundTask.stopService();
        } finally {
          exit(0);
        }
      },
      child: Scaffold(
        body: Center(
          child: Text(
            "Nice Share",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _init() async {
    await ServerTaskHandler.startServerService();
    try {
      await ServerBridge.instance.ensureServerRunning();
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => MainShell()));
      }
    } catch (_) {
      await FlutterForegroundTask.stopService();
      exit(0);
    }
  }
}
