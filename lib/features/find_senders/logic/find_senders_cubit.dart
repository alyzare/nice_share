import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class FindSendersCubit extends Cubit<Map<Sender, SenderStatus>> {
  final SessionsCubit sessionsCubit;

  FindSendersCubit({required this.sessionsCubit}) : super({}) {
    _initUdpSocket();
  }

  late RawDatagramSocket _udpSocket;
  StreamSubscription<RawSocketEvent>? _subscription;

  Future<void> _initUdpSocket() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12459);
    _subscription = _udpSocket.listen((event) {
      if (event != RawSocketEvent.read) return;

      final datagram = _udpSocket.receive();
      if (datagram == null) return;

      if (String.fromCharCodes(datagram.data.sublist(0, 3)) != "NSS") return;

      final sessionId = ByteData.sublistView(
        datagram.data.sublist(3, 11),
      ).getUint64(0, Endian.big);

      final port = ByteData.sublistView(
        datagram.data.sublist(11, 15),
      ).getUint32(0);
      final sender = Sender(
        address: datagram.address,
        port: port,
        sessionId: sessionId,
      );
      if (state.containsKey(sender)) return;

      emit(Map.unmodifiable({...state, sender: SenderStatus.idle}));
    });
  }

  Future<void> sessionSelected(Sender sender) async {
    emit(Map.unmodifiable({...state}..[sender] = SenderStatus.asking));
    final result = await sessionsCubit.addSession(
      SessionModel.blueprint(type: .receive, sender: sender),
    );
    emit(
      Map.unmodifiable(
        {...state}
          ..[sender] = result ? SenderStatus.granted : SenderStatus.refused,
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum SenderStatus {
  idle(true),
  asking(false),
  granted(false),
  refused(true);

  final bool canRequest;

  const SenderStatus(this.canRequest);
}
