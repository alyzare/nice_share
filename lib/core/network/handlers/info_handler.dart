import 'package:nice_share/core/models/peer_model.dart';

class InfoHandler {
  final Map<String, dynamic> _info;
  final Future<String?> Function(PeerModel peer) _askPermission;

  InfoHandler({
    required Map<String, dynamic> info,
    required Future<String?> Function(PeerModel peer) askPermission,
  }) : _info = info,
       _askPermission = askPermission;

  Future<Map<String, dynamic>?> getInfo(PeerModel peer) async {
    final token = await _askPermission(peer);
    return token == null ? null : {..._info, "token": token};
  }
}
