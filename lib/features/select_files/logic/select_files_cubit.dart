import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_model.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

import 'package:path_provider/path_provider.dart';

part 'select_file_state.dart';

class SelectFilesCubit extends Cubit<SelectFileState> {
  final bool isWeb;
  final SessionsCubit sessionsCubit;

  SelectFilesCubit(this.sessionsCubit, {this.isWeb = false})
    : super(LoadedFiles(files: List.unmodifiable([])));

  void addFiles() async {
    emit(LoadingFiles(files: state.files));
    final files = await FilePicker.pickFiles(allowMultiple: true);

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
    final session = SessionModel.blueprint(
      type: isWeb ? .webShare : .send,
      files: state.files,
    );
    sessionsCubit.addSession(session);
    emit(SessionCreated(files: state.files));
  }
}
