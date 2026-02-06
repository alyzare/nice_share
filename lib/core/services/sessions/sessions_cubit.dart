import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/network/custom_http_server.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';

part 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final _server = CustomHttpServer.instance;

  SessionsCubit() : super(SessionsState.empty());

  void addSession(BaseSession session) {
    _server.addSession(session);
    emit(state.addSession(session));
  }

  void stopSession(BaseSession session) {
    _server.stopSession(session);
    emit(state.removeSession(session));
  }

  @override
  Future<void> close() {
    for (final session in state.sessions) {
      session.close();
    }
    return super.close();
  }
}
