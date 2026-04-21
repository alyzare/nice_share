import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_blueprint.dart';
import 'package:nice_share/core/services/choose_file/select_file_state.dart';
import 'package:nice_share/core/services/web_session/web_session_cubit.dart';
import 'package:path_provider/path_provider.dart';

class SelectFilesCubit extends Cubit<SelectFileState> {
  final bool isWeb;
  SelectFilesCubit([this.isWeb = false])
    : super(LoadedFiles(files: List.unmodifiable([])));

  void addFiles() async {
    emit(LoadingFiles(files: state.files));
    final files = await FilePicker.platform.pickFiles(allowMultiple: true);

    emit(
      LoadedFiles(
        files: List.unmodifiable([
          ...state.files,
          ...files?.paths.map((e) => File(e!)) ?? [],
        ]),
      ),
    );
  }

  void removeFile(File file) {
    getApplicationCacheDirectory().then((dir) {
      if (file.path.startsWith(dir.path)) file.delete();
    });
    emit(
      LoadedFiles(
        files: List.unmodifiable(state.files.where((e) => e.path != file.path)),
      ),
    );
  }

  @override
  Future<void> close() {
    if (state is! SessionCreated) {
      getApplicationCacheDirectory().then((dir) {
        for (final file in state.files) {
          if (file.path.startsWith(dir.path)) file.delete();
        }
      });
    }
    return super.close();
  }

  void startSession() {
    final session = SessionBlueprint(
      sessionId: isWeb
          ? WebSessionCubit.newId
          : DateTime.now().millisecondsSinceEpoch,
      type: isWeb ? .webShare : .send,
      files: state.files,
    );
    emit(SessionCreated(session: session, files: state.files));
  }
}
