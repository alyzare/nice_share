import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/choose_file/select_file_state.dart';

class SelectFilesCubit extends Cubit<SelectFileState> {
  SelectFilesCubit() : super(LoadedFiles(files: List.unmodifiable([])));

  void addFiles() async {
    emit(LoadingFiles(files: state.files));
    final files = await FilePicker.platform.pickFiles(allowMultiple: true);

    // emit(
    //   List.unmodifiable([...state, ...files?.paths.map((e) => File(e!)) ?? []]),
    // );

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
    // emit(List.unmodifiable(state.where((e) => e.path != file.path)));
    emit(
      LoadedFiles(
        files: List.unmodifiable(state.files.where((e) => e.path != file.path)),
      ),
    );
  }
}
