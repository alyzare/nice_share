import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/send_session/send_session_cubit.dart';

part 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  SessionsCubit() : super(SessionsState.empty());

  void addSendSession(SendSessionCubit session) =>
      emit(state.addSendSession(session));

  void stopSendSession(SendSessionCubit session) =>
      emit(state.removeSendSession(session));

  @override
  Future<void> close() {
    for (final session in state.sendSessions) {
      session.close();
    }
    return super.close();
  }
}
