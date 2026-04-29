import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/features/home/presentation/components/receive_files_dialog.dart';
import 'package:nice_share/features/home/presentation/components/select_files_bottom_sheet.dart';
import 'package:nice_share/features/home/presentation/components/select_files_dialog.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _checkPermission();
    super.initState();
  }

  late final _buttonMap = [
    _ButtonModel(title: "Send", onTap: _send, icon: Icons.send_rounded),
    _ButtonModel(
      title: "Web Share",
      onTap: _webShare,
      icon: Icons.language_rounded,
    ),
    _ButtonModel(
      title: "Receive",
      onTap: _receive,
      icon: Icons.file_download_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: .spaceEvenly,
              spacing: 10,
              children: _buttonMap
                  .map(
                    (e) => IconButton.filledTonal(
                      onPressed: e.onTap,
                      icon: SizedBox(
                        width: MediaQuery.of(context).size.width / 3 - 40,
                        child: Column(
                          spacing: 5,
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(128),
                                shape: .circle,
                              ),
                              child: Icon(
                                e.icon,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceBright,
                              ),
                            ),
                            Text(e.title),
                          ],
                        ),
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  )
                  .toList(),
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

  void _send() => Platform.isAndroid || Platform.isIOS
      ? SelectFilesBottomSheet.show(context)
      : SelectFilesDialog.show(context);

  void _webShare() => Platform.isAndroid || Platform.isIOS
      ? SelectFilesBottomSheet.show(context, isWeb: true)
      : SelectFilesDialog.show(context, isWeb: true);

  void _receive() async {
    ReceiveFilesDialog.show(context);
  }
}

class _ButtonModel {
  final String title;
  final VoidCallback onTap;
  final IconData icon;

  _ButtonModel({required this.title, required this.onTap, required this.icon});
}
