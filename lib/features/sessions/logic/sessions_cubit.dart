import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/peer_model.dart';
import 'package:nice_share/core/models/permission_request.dart';
import 'package:nice_share/core/models/send_session_model.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/models/upload_permission_request.dart';
import 'package:nice_share/core/services/server_bridge/server_bridge.dart';

class SessionsCubit extends Cubit<List<SessionModel>> {
  ServerBridge get server => ServerBridge.instance;

  SessionsCubit() : super(List.unmodifiable([])) {
    ServerBridge.instance.sessionsCubit = this;
    updateSessions();
  }

  final List<StreamSubscription<PermissionRequest>> _subs = [];

  final Map<UploadPermissionRequest, Completer<bool>>
  _uploadPermissionCompleters = {};

  final _permissionRequestsController =
      StreamController<PermissionRequest>.broadcast();

  final _uploadPermissionRequestsController =
      StreamController<UploadPermissionRequest>.broadcast();

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

  Stream<UploadPermissionRequest> get uploadPermissionRequests =>
      _uploadPermissionRequestsController.stream;

  void updateSessions() async {
    final sessions = await server.getSessions();
    emit(List.unmodifiable(sessions));
  }

  Future<bool> addSession(SessionModel sessionBlueprint) async {
    final session = await server.createSession(sessionBlueprint);
    if (session != null) {
      emit(List.unmodifiable([...state, session]));
      return true;
    }
    return false;
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

  Future<bool> askUploadPermission({
    required UploadPermissionRequest request,
  }) async {
    final completer = Completer<bool>();
    _uploadPermissionCompleters[request] = completer;

    _uploadPermissionRequestsController.add(request);

    return completer.future.timeout(.new(seconds: 10), onTimeout: () => false);
  }

  void setPermission(PermissionRequest request, bool answer) {
    final session = state
        .whereType<SendSessionModel>()
        .where((element) => element.sessionId == request.sessionId)
        .firstOrNull;
    session?.setPermission(peer: request.peer, answer: answer);
  }

  void setUploadPermission(UploadPermissionRequest request, bool answer) {
    final completer = _uploadPermissionCompleters[request];
    if (completer == null) return;

    completer.complete(answer);
  }

  void refresh(List<SessionModel> list) {
    emit(List.unmodifiable(list));
  }
}
