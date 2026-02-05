part of 'send_session_cubit.dart';

sealed class SendSessionState {}

final class SendSessionBroadcasting extends SendSessionState {}

final class SendSessionConnected extends SendSessionState {
  final String peerName;

  SendSessionConnected({required this.peerName});

  SendSessionProgressing toProgressing(Map<File, double> progress) {
    return SendSessionProgressing(progress: progress, peerName: peerName);
  }
}

final class SendSessionProgressing extends SendSessionConnected {
  final Map<File, double> progress;

  SendSessionProgressing({required this.progress, required super.peerName});

  SendSessionProgressing copyWith({Map<File, double>? progress}) {
    return SendSessionProgressing(
      progress: progress ?? this.progress,
      peerName: peerName,
    );
  }
}
