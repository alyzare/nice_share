import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';

part 'send_session_state.dart';

class SendSessionCubit extends Cubit<SendSessionState> with BaseSession {
  @override
  final List<File> files;
  @override
  final int sessionId;

  SendSessionCubit({required this.files, required this.sessionId})
    : super(SendSessionBroadcasting()) {
    _udpTimer = Timer.periodic(Duration(milliseconds: 500), _broadcastAddress);
  }

  late final Timer _udpTimer;
  late final _broadcastMessage = Uint8List.fromList([
    ..."NSS".codeUnits,
    ...(ByteData(8)..setInt64(0, sessionId)).buffer.asUint8List(),
    ...(ByteData(4)..setInt32(0, files.length)).buffer.asUint8List(),
  ]);

  Future<void> _broadcastAddress(Timer timer) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    socket.send(_broadcastMessage, InternetAddress('255.255.255.255'), 12459);
    socket.close();
  }

  @override
  Future<void> close() {
    _udpTimer.cancel();
    return super.close();
  }
}
