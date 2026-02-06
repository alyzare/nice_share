part of 'sessions_cubit.dart';

class SessionsState {
  final List<BaseSession> sessions;

  const SessionsState({this.sessions = const []});

  SessionsState.empty() : sessions = const [];

  SessionsState addSession(BaseSession session) =>
      SessionsState(sessions: List.unmodifiable([...sessions, session]));

  SessionsState removeSession(BaseSession session) {
    session.close();
    return SessionsState(
      sessions: List.unmodifiable(sessions.where((e) => e != session)),
    );
  }
}
