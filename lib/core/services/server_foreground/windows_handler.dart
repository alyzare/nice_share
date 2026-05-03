import 'dart:async';

import 'package:nice_share/core/services/server_foreground/base_handler.dart';
import 'package:nice_share/core/services/server_sessions/sessions_manager.dart';

class WindowsHandler with BaseHandler {
  @override
  late final sessionsManager = SessionsManager(handler: this);

  @override
  Future<void> close() async {
    _messageController.close();
  }

  @override
  void sendDataToUI(Object data) => _messageController.sink.add(data);

  final _messageController = StreamController<Object>.broadcast();

  void addHandler(void Function(Object data) callback) =>
      _messageController.stream.listen(callback);

  static WindowsHandler get instance => _instance;

  static final WindowsHandler _instance = WindowsHandler._();

  WindowsHandler._();
}
