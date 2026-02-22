import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/network/custom_server.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/nice_share_app.dart';

Future<void> main() async {
  final server = await CustomServer.start();
  runApp(
    BlocProvider(
      create: (context) => SessionsCubit(server),
      child: NiceShareApp(),
    ),
  );
}
