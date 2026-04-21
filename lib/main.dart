import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/core/utils.dart';
import 'package:nice_share/nice_share_app.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  final server = await CustomServer.start();
  await Hive.initFlutter();
  final prefBox = await Hive.openBox("pref");
  String? peerName = prefBox.get('name');
  if (peerName == null || peerName.isEmpty) {
    peerName = await getDeviceName();
    await prefBox.put('name', peerName);
  }

  getApplicationCacheDirectory().then((cacheDir) {
    cacheDir.delete(recursive: true);
  });

  runApp(
    BlocProvider(
      create: (context) => SessionsCubit(server: server, peerName: peerName!),
      child: NiceShareApp(),
    ),
  );
}
