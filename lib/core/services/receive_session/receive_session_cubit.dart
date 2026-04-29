import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_type.dart';
import 'package:nice_share/core/network/handlers/file_handler.dart';
import 'package:nice_share/core/network/request_helper.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';
import 'package:path_provider/path_provider.dart' as p;

part 'receive_session_state.dart';

class ReceiveSessionCubit extends Cubit<ReceiveSessionState> with BaseSession {
  @override
  int get sessionId => requestHelper.sender.sessionId;

  @override
  late final List<FileHandler> fileHandlers;

  final RequestHelper requestHelper;

  ReceiveSessionCubit({
    required this.requestHelper,
    required List<String> paths,
  }) : super(ReceiveSessionInitial()) {
    _initFiles(paths);
  }

  void _initFiles(List<String> paths) async {
    final basePath = await p.getDownloadsDirectory();
    await basePath!.create(recursive: true);
    //todo
    // files = paths
    //     .map((path) => File('$basePath/${pathlib.basename(path)}'))
    //     .toList();
  }

  @override
  SessionType get type => .receive;
}
