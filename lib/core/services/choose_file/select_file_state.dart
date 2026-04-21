import 'dart:io';

sealed class SelectFileState {
  final List<File> files;

  SelectFileState({required this.files});
}

class LoadingFiles extends SelectFileState {
  LoadingFiles({required super.files});
}

class LoadedFiles extends SelectFileState {
  LoadedFiles({required super.files});
}

class ErrorLoadingFiles extends LoadedFiles {
  final String error;

  ErrorLoadingFiles({required this.error, super.files = const []});
}
