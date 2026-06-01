part of 'base_handler.dart';

class WindowsHandler with BaseHandler {
  @override
  Future<void> close() async {
    _messageController.close();
  }

  @override
  void sendDataToUI(Message message) => _messageController.sink.add(message);

  final _messageController = StreamController<Message>.broadcast();

  void addHandler(void Function(Message message) callback) =>
      _messageController.stream.listen(callback);

  static WindowsHandler get instance => _instance;

  static final WindowsHandler _instance = WindowsHandler._();

  WindowsHandler._();
}
