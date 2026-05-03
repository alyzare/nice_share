import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/services/server_foreground/base_handler.dart';
import 'package:nice_share/core/services/server_sessions/sessions_manager.dart';

class ServerTaskHandler extends TaskHandler with BaseHandler {
  @override
  late final sessionsManager = SessionsManager(handler: this);

  @override
  Future<void> close() async {
    (await server.future).close();
    sendDataToUI({"type": "server_stopped"});
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async => close();

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint("Foreground starting...");
    await start();
    final port = (await server.future).port;
    FlutterForegroundTask.updateService(
      notificationTitle: "Nice Share Running",
      notificationText: "On port: $port",
    );
    debugPrint("Foreground started on port: $port");
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == "stop") {
      FlutterForegroundTask.stopService();
    }
    super.onNotificationButtonPressed(id);
  }

  @override
  void sendDataToUI(Object data) => FlutterForegroundTask.sendDataToMain(data);
}
