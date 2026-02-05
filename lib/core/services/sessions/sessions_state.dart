part of 'sessions_cubit.dart';

class SessionsState {
  final List<SendSessionCubit> sendSessions;

  const SessionsState({this.sendSessions = const []});

  SessionsState.empty() : sendSessions = const [];

  SessionsState addSendSession(SendSessionCubit session) => SessionsState(
    sendSessions: List.unmodifiable([...sendSessions, session]),
  );

  SessionsState removeSendSession(SendSessionCubit session) {
    session.close();
    return SessionsState(
      sendSessions: List.unmodifiable(sendSessions.where((e) => e != session)),
    );
  }
}
