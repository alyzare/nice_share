import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/models/message.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/sessions_event.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/server_bridge/server_bridge.dart';
import 'package:nice_share/core/services/server_sessions/sessions_manager.dart';

part 'server_task_handler.dart';

part 'windows_handler.dart';

mixin BaseHandler {
  final server = Completer<CustomServer>();

  final Map<int, Completer<bool>> permissionCompleters = {};

  Future<int> get serverPort async => (await server.future).port;

  SessionsManager get sessionsManager;

  void sendDataToUI(Message message);

  Future<void> close();

  Future<bool> askPermission({
    required PeerModel peer,
    required int sessionId,
  }) {
    final completer = Completer<bool>();
    final messageId = DateTime.now().microsecondsSinceEpoch;
    permissionCompleters[messageId] = completer;

    final message = Message(
      type: .askPermission,
      id: messageId,
      payload: {"id": sessionId, "peer": peer.toMap},
    );

    sendDataToUI(message);

    return completer.future.timeout(.new(seconds: 15), onTimeout: () => false);
  }

  Future<void> start() async => server.complete(
    await CustomServer.start(sessionManager: sessionsManager),
  );

  Future<void> onReceiveData(Object data) async {
    if (data is! Map<String, dynamic> ||
        (data["type"] != null && data["type"] is! int)) {
      return;
    }

    final message = Message.fromMap(data);

    if (message.type != .unknown) {
      late final Map<String, Object> payload;

      switch (message.type) {
        case .ensureServerRunning:
          payload = {"port": await serverPort};
        case .session:
          assert(message.action != null);
          final id = await sessionsManager.addEvent(
            SessionsEvent.byAction(message.action!, message.payload),
          );
          payload = {"id": id};
        case .getAll:
          final sessions = sessionsManager.sessions;
          payload = {
            "sessions": sessions
                .map((session) => session.toMap())
                .toList(growable: false),
          };
        case _:
      }

      final resultMessage = Message(
        type: .unknown,
        id: message.id,
        payload: payload,
      );
      sendDataToUI(resultMessage);
      debugPrint("DATA SENT TO MAIN: $resultMessage");
    } else {
      permissionCompleters[message.id]?.complete(
        (message.payload["answer"] as bool?) ?? false,
      );
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
    sendDataToUI(Message(type: .refresh, payload: {"sessions": sessions}));
  }
}

@pragma("vm:entry-point")
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(ServerTaskHandler());
}
