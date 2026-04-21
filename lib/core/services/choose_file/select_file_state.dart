import 'dart:io';

import 'package:nice_share/core/models/session_blueprint.dart';

sealed class SelectFileState {
  final List<File> files;

  SelectFileState({required this.files});

  bool get isLoadingFiles => this is LoadingFiles;
}

class LoadingFiles extends SelectFileState {
  LoadingFiles({required super.files});
}

class LoadedFiles extends SelectFileState {
  LoadedFiles({required super.files});
}

class SessionCreated extends SelectFileState {
  final SessionBlueprint session;
  SessionCreated({required this.session, required super.files});
}

class ErrorLoadingFiles extends LoadedFiles {
  final String error;

  ErrorLoadingFiles({required this.error, super.files = const []});
}
