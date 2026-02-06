import 'package:dio/dio.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/services/receive_session/receive_session_cubit.dart';

class RequestHelper {
  final Sender sender;

  RequestHelper(this.sender);

  late final _dio = Dio(
    BaseOptions(
      baseUrl: "http://${sender.address.address}:${sender.port}",
      headers: {"X-Session-Id": sender.sessionId.toString()},
    ),
  );

  Future<ReceiveSessionCubit> getReceiveSession() async {
    try {
      final response = await _dio.get(
        '',
        options: Options(headers: {"X-Request-Type": "info"}),
      );
      return ReceiveSessionCubit(
        requestHelper: this,
        paths: response.data['files'],
      );
    } catch (e) {
      // TODO
      rethrow;
    }
  }
}
