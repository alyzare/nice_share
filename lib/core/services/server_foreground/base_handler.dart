import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/sessions_event.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';
import 'package:nice_share/core/services/server_foreground/windows_handler.dart';
import 'package:nice_share/core/services/server_sessions/sessions_manager.dart';

import 'server_task_handler.dart';

mixin BaseHandler {
  final server = Completer<CustomServer>();

  final Map<int, Completer<bool>> permissionCompleters = {};

  Future<int> get serverPort async => (await server.future).port;

  SessionsManager get sessionsManager;

  void sendDataToUI(Object data);

  Future<void> close();

  Future<bool> askPermission({
    required PeerModel peer,
    required int sessionId,
  }) {
    final completer = Completer<bool>();
    final messageId = DateTime.now().microsecondsSinceEpoch;
    permissionCompleters[messageId] = completer;

    sendDataToUI({
      "type": "ask_permission",
      "id": messageId,
      "payload": {"id": sessionId, "peer": peer.toMap},
    });

    return completer.future.timeout(.new(seconds: 15), onTimeout: () => false);
  }

  Future<void> start() async => server.complete(
    await CustomServer.start(sessionManager: sessionsManager),
  );

  Future<void> onReceiveData(Object data) async {
    print("onReceiveData CALLED $data");
    if (data is! Map<String, dynamic> ||
        (data["type"] != null && data["type"] is! String)) {
      return;
    }

    final type = data["type"] as String?;
    if (type == "ensure_server_running") {
      print("HELLO");
    }
    final id = data["id"] as int;
    if (type != null) {
      final result = <String, Object?>{"id": id};

      switch (type) {
        case "ensure_server_running":
          result["data"] = await serverPort;
        case "session":
          final id = await sessionsManager.addEvent(
            SessionsEvent.byAction(data["action"] as String, data["payload"]),
          );
          result["data"] = {"id": id};
        case "get_all":
          final sessions = sessionsManager.sessions;
          result["data"] = sessions
              .map((session) => session.toMap())
              .toList(growable: false);
      }

      sendDataToUI(result);
      debugPrint("DATA SENT TO MAIN: $result");
    } else {
      permissionCompleters[id]?.complete(data["payload"] ?? false);
    }
  }

  static Future<void> startServerService() {
    if (Platform.isAndroid) {
      return _startAndroidService();
    } else if (Platform.isWindows) {
      return _startWindowsService();
    }
    throw UnsupportedError("Unsupported platform");
  }

  static Future<void> _startAndroidService() async {
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

  static Future<void> _startWindowsService() async {
    await WindowsHandler.instance.start();
    WindowsHandler.instance.addHandler(ServerBridge.instance.handleMessage);
  }

  Future<void> refresh() async {
    final sessions = sessionsManager.sessions.map((e) => e.toMap()).toList();
    sendDataToUI({"type": "refresh", "payload": sessions});
  }
}

@pragma("vm:entry-point")
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(ServerTaskHandler());
}
