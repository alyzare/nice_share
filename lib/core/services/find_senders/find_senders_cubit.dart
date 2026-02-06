import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';

class FindSendersCubit extends Cubit<List<Sender>> {
  FindSendersCubit() : super(List.empty()) {
    _initUdpSocket();
  }

  RawDatagramSocket? _udpSocket;
  StreamSubscription<RawSocketEvent>? _subscription;

  Future<void> _initUdpSocket() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12459);
    _subscription = _udpSocket!.listen((event) {
      print("EVENT $event");
      if (event != RawSocketEvent.read) return;

      final datagram = _udpSocket!.receive();
      if (datagram == null) return;

      if (String.fromCharCodes(datagram.data.sublist(0, 3)) != "NSS") return;

      final sessionId = ByteData.sublistView(
        datagram.data.sublist(3, 11),
      ).getUint64(0, Endian.big);

      final port = ByteData.sublistView(
        datagram.data.sublist(11, 15),
      ).getUint32(0);

      if (state.any((element) => element.sessionId == sessionId)) return;

      emit(
        List.unmodifiable([
          ...state,
          Sender(address: datagram.address, port: port, sessionId: sessionId),
        ]),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
