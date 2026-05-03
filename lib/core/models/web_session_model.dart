import 'package:nice_share/core/models/session_model.dart';

class WebSessionModel extends SessionModel {
  WebSessionModel({required super.sessionId, required super.files})
    : super(type: .webShare);
}
