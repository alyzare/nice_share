import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/components/responsive_modal.dart';
import 'package:nice_share/features/find_senders/logic/find_senders_cubit.dart';
import 'package:nice_share/features/find_senders/presentation/find_senders.dart';
import 'package:nice_share/features/info/presentation/info.dart';
import 'package:nice_share/features/select_files/logic/select_files_cubit.dart';
import 'package:nice_share/features/select_files/presentation/select_files.dart';
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

  late final _buttonsMap = [
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
              children: _buttonsMap
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
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: _showInfo,
                  child: Text("Info"),
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

  void _send() => context.showResponsiveModal(
    isScrollable: true,
    child: BlocProvider(
      create: (_) => SelectFilesCubit(context.read()),
      child: SelectFiles(),
    ),
  );

  void _webShare() => context.showResponsiveModal(
    isScrollable: true,
    child: BlocProvider(
      create: (_) => SelectFilesCubit(context.read(), isWeb: true),
      child: SelectFiles(),
    ),
  );

  void _receive() => context.showResponsiveModal(
    isScrollable: true,
    child: BlocProvider(
      create: (_) => FindSendersCubit(sessionsCubit: context.read()),
      child: FindSenders(),
    ),
  );

  void _showInfo() => context.showResponsiveModal(child: Info());
}

class _ButtonModel {
  final String title;
  final VoidCallback onTap;
  final IconData icon;

  _ButtonModel({required this.title, required this.onTap, required this.icon});
}
