import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/send_session/send_session_cubit.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:path/path.dart' as p;
import 'package:nice_share/core/services/choose_file/select_files_cubit.dart';

class SelectFilesDialog extends StatefulWidget {
  const SelectFilesDialog._();

  @override
  State<SelectFilesDialog> createState() => _SelectFilesDialogState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SelectFilesDialog._(),
    );
  }
}

class _SelectFilesDialogState extends State<SelectFilesDialog> {
  late final _cubit = SelectFilesCubit();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
      clipBehavior: .antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                "Select files to send",
                style: TextStyle(fontWeight: .bold),
              ),
            ),
          ),
          BlocBuilder<SelectFilesCubit, List<File>>(
            bloc: _cubit,
            builder: (context, state) {
              return Expanded(
                child: state.isNotEmpty
                    ? ListView.separated(
                        itemCount: state.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final file = state[index];
                          return ListTile(
                            title: Text(p.basename(file.path)),
                            subtitle: Text(file.path),
                            trailing: IconButton(
                              onPressed: () => _cubit.removeFile(file),
                              icon: Icon(Icons.close),
                            ),
                          );
                        },
                      )
                    : Center(child: Text("Empty")),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: _cubit.addFiles,
              child: Text("Select files"),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ).copyWith(bottom: 8),
            child: FilledButton(
              onPressed: () {
                final session = SendSessionCubit(
                  files: _cubit.state,
                  sessionId: DateTime.now().millisecondsSinceEpoch,
                );
                context.read<SessionsCubit>().addSendSession(session);
                Navigator.of(context).pop();
              },
              child: Text("Send"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
