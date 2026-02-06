import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/network/request_helper.dart';
import 'package:nice_share/core/services/base_session/base_session.dart';
import 'package:path_provider/path_provider.dart' as p;
import 'package:path/path.dart' as pathlib;

part 'receive_session_state.dart';

class ReceiveSessionCubit extends Cubit<ReceiveSessionState> with BaseSession {
  @override
  int get sessionId => requestHelper.sender.sessionId;

  @override
  late final List<File> files;

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
    files = paths
        .map((path) => File('$basePath/${pathlib.basename(path)}'))
        .toList();
  }
}
