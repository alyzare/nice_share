import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/network/request_helper.dart';
import 'package:nice_share/core/services/server_foreground/global_id_service.dart';
import 'package:nice_share/core/services/server_sessions/base_session.dart';

class ReceiveSession with BaseSession {
  @override
  final int sessionId;

  @override
  final List<FileHandler> fileHandlers;

  @override
  SessionType get type => .receive;

  @override
  Map<String, Object?> toMap() {
    return super.toMap()..addAll({"sender": sender.toMap});
  }

  final Sender sender;

  final RequestHelper requestHelper;

  ReceiveSession._({
    required this.sessionId,
    required this.fileHandlers,
    required this.sender,
    required this.requestHelper,
  }) {
    _start();
  }

  Future<void> _start() async {
    for (int i = 0; i < fileHandlers.length; i++) {
      await requestHelper.getFile(i, fileHandlers[i].path);
    }
    close();
  }

  static Future<ReceiveSession> getFromSender(Sender sender) async {
    final requestHelper = RequestHelper(sender);

    try {
      final info = await requestHelper.getInfo();
      final filesInfo = (info["files"] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>();
      if (filesInfo == null || filesInfo.isEmpty) throw "No files";

      final files = await FileHandler.listToReceive(filesInfo);

      return ReceiveSession._(
        sessionId: GlobalIdService.newId,
        fileHandlers: files,
        sender: sender,
        requestHelper: requestHelper,
      );
    } catch (_) {
      throw "Permission Denied";
    }
  }
}
