import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/sessions_event.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';
import 'package:nice_share/core/services/sessions/sessions_manager.dart';

class ServerTaskHandler extends TaskHandler {
  final Completer<CustomServer> _server = Completer();
  final sessionsManager = SessionsManager();

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await (await _server.future).close();
    FlutterForegroundTask.sendDataToMain({"type": "server_stopped"});
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint("Foreground starting...");
    _server.complete(CustomServer.start(sessionManager: sessionsManager));
    final port = (await _server.future).port;
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
  Future<void> onReceiveData(Object data) async {
    debugPrint("DATA RECEIVED FROM MAIN $data");
    if (data is! Map<String, dynamic> ||
        data["type"] == null ||
        data["type"] is! String) {
      return;
    }

    final type = data["type"] as String;
    final id = data["id"] as int;
    final result = <String, Object?>{"id": id};

    switch (type) {
      case "ensure_server_running":
        result["data"] = (await _server.future).port;
      case "session":
        final id = (await _server.future).sessionsManager.addEvent(
          SessionsEvent.byAction(data["action"] as String, data["payload"]),
        );
        result["data"] = {"id": id};
      case "get_all":
        final sessions = (await _server.future).sessionsManager.sessions;
        result["data"] = sessions
            .map((session) => session.toMap())
            .toList(growable: false);
    }

    FlutterForegroundTask.sendDataToMain(result);
    debugPrint("DATA SENT TO MAIN: $result");
  }

  static Future<void> startServerService() async {
    FlutterForegroundTask.addTaskDataCallback(
      ServerBridge.instance.handleMessage,
    );
    if ((await FlutterForegroundTask.checkNotificationPermission()) !=
        NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (!(await FlutterForegroundTask.isRunningService)) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: "foreground_service",
          channelName: "Foreground Service Notification",
        ),
        iosNotificationOptions: IOSNotificationOptions(),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(1000),
          allowWakeLock: true,
          allowWifiLock: true,
          autoRunOnBoot: true,
        ),
      );

      final res = await FlutterForegroundTask.startService(
        notificationTitle: "Server Running",
        notificationText: "On port: ",
        notificationButtons: [NotificationButton(id: "stop", text: "Stop")],
        callback: _startCallback,
      );

      if (res is ServiceRequestFailure) {
        debugPrint("ERROR on foreground: ${res.error}");
      } else {
        debugPrint("foreground result: $res");
      }
    }
  }
}

@pragma("vm:entry-point")
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(ServerTaskHandler());
}
