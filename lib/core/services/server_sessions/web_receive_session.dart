import 'dart:math';

import 'package:nice_share/core/models/session_type.dart';

import 'package:nice_share/core/network/handlers/file_handler.dart';

import 'base_session.dart';

class WebReceiveSession with BaseSession {
  @override
  final int sessionId;

  @override
  final List<FileHandler> fileHandlers;

  @override
  SessionType get type => .webReceive;

  final String token;

  WebReceiveSession({required this.sessionId, required this.fileHandlers})
    : token = _generateToken();

  static String _generateToken() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(256),
    ).map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }
}
