import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/features/home/presentation/components/receive_files_dialog.dart';
import 'package:nice_share/features/home/presentation/components/select_files_bottom_sheet.dart';
import 'package:nice_share/features/home/presentation/components/select_files_dialog.dart';
import 'package:nice_share/features/home/presentation/components/sessions_dialog.dart';
import 'package:nice_share/features/log/log_page.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SessionsCubit _sessionsCubit = context.read();

  @override
  void initState() {
    _checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Nice Share"),
        leading: BlocBuilder<SessionsCubit, int>(
          builder: (_, state) {
            return IconButton(
              onPressed: state == 0 ? null : () => SessionsDialog.show(context),
              icon: state == 0
                  ? SizedBox.shrink()
                  : Text(_sessionsCubit.sessions.length.toString()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      LogPage(logs: _sessionsCubit.server.requestLogs),
                ),
              );
            },
            icon: Icon(Icons.developer_mode_rounded),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              OutlinedButton(
                onPressed: () async {
                  final session = await (Platform.isAndroid || Platform.isIOS
                      ? SelectFilesBottomSheet.show(context)
                      : SelectFilesDialog.show(context));
                  if (session == null) return;
                  _sessionsCubit.addSession(session);
                },
                child: Text("Send"),
              ),
              OutlinedButton(
                onPressed: () async {
                  final session = await (Platform.isAndroid || Platform.isIOS
                      ? SelectFilesBottomSheet.show(context, isWeb: true)
                      : SelectFilesDialog.show(context, isWeb: true));
                  if (session == null) return;
                  _sessionsCubit.addSession(session);
                },
                child: Text("Send via web"),
              ),
              OutlinedButton(
                onPressed: () {
                  ReceiveFilesDialog.show(context);
                },
                child: Text("Receive"),
              ),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Port: "),
                      TextSpan(
                        text: context
                            .read<SessionsCubit>()
                            .server
                            .port
                            .toString(),
                        style: TextStyle(fontWeight: .bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkPermission() async {
    if (!Platform.isAndroid) return;

    final permissionStatus =
        await permission_handler.Permission.manageExternalStorage.status;

    if (permissionStatus == permission_handler.PermissionStatus.granted) return;

    final result = await permission_handler.Permission.manageExternalStorage
        .request();
    debugPrint(result.toString());
  }
}
