import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseFileCubit extends Cubit<List<File>> {
  ChooseFileCubit() : super(List.unmodifiable([]));

  void addFiles() async {
    final files = await FilePicker.platform.pickFiles();
    emit(
      List.unmodifiable([...state, ...files?.paths.map((e) => File(e!)) ?? []]),
    );
  }

  void removeFile(File file) {
    emit(List.unmodifiable(state.where((e) => e.path != file.path)));
  }
}
