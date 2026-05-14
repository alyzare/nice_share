import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/services/pref/pref_service.dart';

class RequestHelper {
  final Sender _sender;

  RequestHelper(Sender sender) : _sender = sender;

  late final String token;

  late final _dio = Dio(
    BaseOptions(
      baseUrl: "http://${_sender.address.address}:${_sender.port}",
      headers: {"X-Session-Id": _sender.sessionId.toString()},
    ),
  );

  Future<Map<String, dynamic>> getInfo() async {
    try {
      final response = await _dio.get(
        '/session/${_sender.sessionId}',
        options: Options(headers: {"X-Peer-Name": PrefService.peerName}),
      );
      token = response.data["token"] as String;
      return (response.data as Map<String, dynamic>).cast();
    } catch (e) {
      // TODO
      rethrow;
    }
  }

  Future<void> getFile(int fileIndex, String path) {
    return _dio.download(
      "/session/${_sender.sessionId}/$fileIndex",
      path,
      onReceiveProgress: (count, total) => debugPrint(
        "File: $fileIndex => ${(count / total * 100).toStringAsFixed(1)}%",
      ),
      options: Options(
        headers: {"X-Token": token, "X-Peer-Name": PrefService.peerName},
      ),
    );
  }
}
