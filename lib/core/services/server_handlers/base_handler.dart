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

    final message = RequestMessage(
      action: .askPermission,
      payload: {"id": sessionId, "peer": peer.toMap},
    );

    permissionCompleters[message.id] = completer;

    sendDataToUI(message);

    return completer.future.timeout(.new(seconds: 15), onTimeout: () => false);
  }

  Future<void> start() async => server.complete(
    await CustomServer.start(sessionManager: sessionsManager),
  );

  Future<void> onReceiveData(dynamic data) async {
    if (data is! Map<String, dynamic> ||
        (data["type"] != null && data["type"] is! int)) {
      return;
    }

    final message = Message.fromMap(data);

    switch (message.type) {
      case MessageType.request:
        _handleRequest(message as RequestMessage);
      case MessageType.response:
        _handleResponse(message as ResponseMessage);
      case MessageType.idle:
        _handleIdleMessage(message as IdleMessage);
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

  void refresh() => sendDataToUI(
    IdleMessage(
      action: .refresh,
      payload: {
        "sessions": sessionsManager.sessions.map((e) => e.toMap()).toList(),
      },
    ),
  );

  Future<void> _handleRequest(RequestMessage request) async {
    final payload = <String, dynamic>{};

    switch (request.action) {
      case .ensureServerRunning:
        payload["port"] = await serverPort;
      case .addSession:
        final id = await sessionsManager.addEvent(
          SessionsEvent.fromPayload(action: .add, payload: payload),
        );
        payload["id"] = id;
      case .stopSession:
        final id = await sessionsManager.addEvent(
          SessionsEvent.fromPayload(action: .stop, payload: payload),
        );
        payload["id"] = id;
      case .updateSession:
        final id = await sessionsManager.addEvent(
          SessionsEvent.fromPayload(action: .update, payload: payload),
        );
        payload["id"] = id;
      case .getAll:
        final sessions = sessionsManager.sessions;
        payload["sessions"] = sessions
            .map((session) => session.toMap())
            .toList(growable: false);
      case _:
    }

    final response = ResponseMessage.ofRequest(request, payload: payload);
    sendDataToUI(response);
  }

  void _handleResponse(ResponseMessage response) {
    switch (response.action) {
      case .askPermission:
        permissionCompleters[response.id]?.complete(
          (response.payload?["answer"] as bool?) ?? false,
        );
      case _:
    }
  }

  void _handleIdleMessage(IdleMessage message) {
    throw UnimplementedError();
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
}

@pragma("vm:entry-point")
void _startCallback() {
  FlutterForegroundTask.setTaskHandler(ServerTaskHandler());
}
