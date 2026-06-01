import 'peer_model.dart';

class PermissionRequest {
  final int sessionId;
  final PeerModel peer;

  PermissionRequest({required this.sessionId, required this.peer});
}
