import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/send_session_model.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';

class SessionsCubit extends Cubit<List<SessionModel>> {
  final String peerName;

  ServerBridge get server => ServerBridge.instance;

  SessionsCubit({required this.peerName}) : super(List.unmodifiable([])) {
    updateSessions();
  }

  final List<StreamSubscription<PermissionRequest>> _subs = [];

  final _permissionRequestsController = StreamController<PermissionRequest>();

  @override
  void onChange(Change<List<SessionModel>> change) {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();

    for (final session in change.nextState.whereType<SendSessionModel>()) {
      final sub = session.permissionRequests?.listen(
        _permissionRequestsController.add,
      );
      if (sub != null) _subs.add(sub);
    }

    super.onChange(change);
  }

  @override
  Future<void> close() async {
    Future.wait(state.whereType<SendSessionModel>().map((e) => e.close()));
    Future.wait(_subs.map((e) => e.cancel()));
    _permissionRequestsController.close();
    return super.close();
  }

  Stream<PermissionRequest> get permissionRequests =>
      _permissionRequestsController.stream;

  void updateSessions() async {
    final sessions = await server.getSessions();
    emit(List.unmodifiable(sessions));
  }

  void addSession(SessionModel sessionBlueprint) async {
    final session = await server.createSession(sessionBlueprint);
    if (session != null) {
      emit(List.unmodifiable([...state, session]));
    }
  }

  void closeSession(int sessionId) async {
    final session = state.where((e) => e.sessionId == sessionId).firstOrNull;
    if (session == null) return;

    try {
      await server.stopSession(session.sessionId);
      if (session is SendSessionModel) {
        session.close();
      }
      emit(List.unmodifiable(state.where((s) => s.sessionId != sessionId)));
    } catch (_) {}
  }

  Future<bool> askPermission({
    required int sessionId,
    required PeerModel peer,
  }) async {
    final answer = state
        .whereType<SendSessionModel>()
        .where((e) => e.sessionId == sessionId)
        .firstOrNull
        ?.askPermission(peer);
    return answer ?? false;
  }

  void setPermission(PermissionRequest request, bool answer) {
    final session = state
        .whereType<SendSessionModel>()
        .where((element) => element.sessionId == request.sessionId)
        .firstOrNull;
    session?.setPermission(peer: request.peer, answer: answer);
  }
}

class PermissionRequest {
  final int sessionId;
  final PeerModel peer;

  PermissionRequest({required this.sessionId, required this.peer});
}
