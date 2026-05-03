import 'package:nice_share/core/models/peer_model.dart';

class InfoHandler {
  final Map<String, Object> _info;
  final Future<String?> Function(PeerModel peer) _askPermission;

  InfoHandler({
    required Map<String, Object> info,
    required Future<String?> Function(PeerModel peer) askPermission,
  }) : _info = info,
       _askPermission = askPermission;

  Future<Map<String, Object>?> getInfo(PeerModel peer) async {
    final token = await _askPermission(peer);
    return token == null ? null : {..._info, "token": token};
  }
}
