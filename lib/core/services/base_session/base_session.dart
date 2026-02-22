import 'dart:io';

import 'package:flutter/cupertino.dart';

mixin BaseSession {
  int get sessionId;

  List<File> get files;

  ValueNotifier<bool> get isClosedNotifier;

  Future<void> close();
}
