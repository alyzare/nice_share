part of 'send_session_cubit.dart';

sealed class SendSessionState {}

final class SendSessionBroadcasting extends SendSessionState {}

final class SendSessionConnected extends SendSessionState {
  final String peerName;

  SendSessionConnected({required this.peerName});

  SendSessionProgressing toProgressing(List<double> progressList) {
    return SendSessionProgressing(
      progressList: progressList,
      peerName: peerName,
    );
  }
}

final class SendSessionProgressing extends SendSessionConnected {
  final List<double> progressList;

  SendSessionProgressing({required this.progressList, required super.peerName});

  SendSessionProgressing copyWith(int index, double progress) {
    return SendSessionProgressing(
      progressList: progressList..[index] = progress,
      peerName: peerName,
    );
  }
}
