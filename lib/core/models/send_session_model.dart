import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/services/permission/permission_cubit.dart';

import 'permission_request.dart';
import 'session_model.dart';

class SendSessionModel extends SessionModel {
  final PermissionCubit? _permissionCubit;

  SendSessionModel({
    super.sessionId = -1,
    required super.files,
    bool createPermissionCubit = false,
    List<PeerModel>? peers,
  }) : _permissionCubit = createPermissionCubit ? PermissionCubit() : null,
       super(type: .send);

  Future<void> close() async => _permissionCubit?.close();

  Future<bool> askPermission(PeerModel peer) async {
    final answer = _permissionCubit?.askPermission(peer);
    return answer ?? false;
  }

  Stream<PermissionRequest>? get permissionRequests => _permissionCubit
      ?.permissionRequests
      .map((peer) => PermissionRequest(sessionId: sessionId, peer: peer));

  void setPermission({required PeerModel peer, required bool answer}) =>
      _permissionCubit?.setResult(peer: peer, result: answer);
}
