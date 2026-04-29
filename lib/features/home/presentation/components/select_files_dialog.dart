import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/utils.dart';
import 'package:path/path.dart' as p;
import 'package:nice_share/core/services/choose_file/select_files_cubit.dart';

class SelectFilesDialog extends StatefulWidget {
  final bool isWeb;

  const SelectFilesDialog._([this.isWeb = false]);

  @override
  State<SelectFilesDialog> createState() => _SelectFilesDialogState();

  static Future<void> show(BuildContext context, {bool isWeb = false}) =>
      showDialog(context: context, builder: (_) => SelectFilesDialog._(isWeb));
}

class _SelectFilesDialogState extends State<SelectFilesDialog> {
  late final _cubit = SelectFilesCubit(context.read(), widget.isWeb);

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
          BlocConsumer<SelectFilesCubit, SelectFileState>(
            bloc: _cubit,
            listenWhen: (_, current) => current is SessionCreated,
            listener: (_, state) {
              if (state is SessionCreated) {
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              return Expanded(
                child: state.files.isNotEmpty
                    ? ListView.separated(
                        itemCount:
                            state.files.length +
                            (state is LoadingFiles ? 1 : 0),
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          if (state is LoadingFiles &&
                              index == state.files.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final file = state.files[index];
                          return ListTile(
                            title: Text(p.basename(file.path)),
                            subtitle: Text(formattedSize(file.lengthSync())),
                            trailing: IconButton(
                              onPressed: () => _cubit.removeFile(file),
                              icon: Icon(Icons.close),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: state is LoadingFiles
                            ? CircularProgressIndicator()
                            : Text("Empty"),
                      ),
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
              onPressed: _cubit.startSession,
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
