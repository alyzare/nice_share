import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_blueprint.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';

part 'sessions_state.dart';

class SessionsCubit extends Cubit<int> {
  final CustomServer server;

  SessionsCubit(this.server) : super(0);

  final List<BaseSession> sessions = [];

  void addSession(SessionBlueprint sessionBlueprint) {
    final session = sessionBlueprint.createSession(server);
    sessions.add(session);
    emit(sessions.length);
    session.isClosedNotifier.addListener(() {
      final isClosed = session.isClosedNotifier.value;
      if (!_isClosing && isClosed) {
        sessions.remove(session);
        emit(sessions.length);
      }
    });
  }

  bool _isClosing = false;

  @override
  Future<void> close() {
    _isClosing = true;
    for (final session in sessions) {
      session.close();
    }
    return super.close();
  }
}
