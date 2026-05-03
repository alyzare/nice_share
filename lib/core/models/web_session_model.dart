import 'package:nice_share/core/models/session_model.dart';

class WebSessionModel extends SessionModel {
  WebSessionModel({super.sessionId = -1, required super.files})
    : super(type: .webShare);
}
