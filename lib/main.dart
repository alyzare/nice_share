import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nice_share/core/services/pref/pref_service.dart';
import 'package:nice_share/core/services/server_foreground/server_bridge.dart';
import 'package:nice_share/features/global_notifications/presentation/global_notifications.dart';
import 'package:nice_share/nice_share_app.dart';
import 'package:path_provider/path_provider.dart';

import 'features/sessions/logic/sessions_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await PrefService.init();

  getApplicationCacheDirectory().then((cacheDir) {
    cacheDir.delete(recursive: true);
  });

  runApp(
    BlocProvider(
      create: (_) {
        final cubit = SessionsCubit();
        ServerBridge.instance.sessionsCubit = cubit;
        return cubit;
      },
      child: GlobalNotifications(child: NiceShareApp()),
    ),
  );
}
