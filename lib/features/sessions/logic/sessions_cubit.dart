import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';

class SessionsCubit extends Cubit<List<SessionModel>> {
  final String peerName;

  SessionsCubit({required this.peerName}) : super(List.unmodifiable([])) {
    updateSessions();
  }

  ServerBridge get server => ServerBridge.instance;

  void addSession(SessionModel sessionBlueprint) async {
    final session = await server.createSession(sessionBlueprint);
    if (session != null) emit(List.unmodifiable([...state, session]));
  }

  void updateSessions() async {
    final sessions = await server.getSessions();
    emit(List.unmodifiable(sessions));
  }
}
