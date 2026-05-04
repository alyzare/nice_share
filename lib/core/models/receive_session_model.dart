import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/models/session_model.dart';

class ReceiveSessionModel extends SessionModel {
  final Sender sender;

  ReceiveSessionModel({
    super.sessionId = -1,
    super.files = const [],
    required this.sender,
  }) : super(type: .receive);

  @override
  Map<String, Object> get toMap =>
      super.toMap..addAll({"sender": sender.toMap});
}
