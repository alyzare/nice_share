import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/utils.dart';
import 'package:path/path.dart' as path;
import 'package:nice_share/core/services/choose_file/select_files_cubit.dart';

class SelectFilesBottomSheet extends StatefulWidget {
  final bool isWeb;

  const SelectFilesBottomSheet._([this.isWeb = false]);

  static Future<void> show(BuildContext context, {bool isWeb = false}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SelectFilesBottomSheet._(isWeb),
      );

  @override
  State<SelectFilesBottomSheet> createState() => _SelectFilesBottomSheetState();
}

class _SelectFilesBottomSheetState extends State<SelectFilesBottomSheet> {
  late final _cubit = SelectFilesCubit(context.read(), widget.isWeb);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectFilesCubit, SelectFileState>(
      bloc: _cubit,
      listenWhen: (_, current) => current is SessionCreated,
      listener: (_, state) {
        if (state is SessionCreated) {
          Navigator.of(context).pop();
        }
      },

      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          expand: false,
          builder: (innerContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Select files to send',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: state.files.isNotEmpty
                        ? ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.files.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              if (state is LoadingFiles &&
                                  index == state.files.length) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final file = state.files[index];
                              return ListTile(
                                title: Text(path.basename(file.path)),
                                subtitle: Text(
                                  formattedSize(file.lengthSync()),
                                ),
                                trailing: IconButton(
                                  onPressed: () => _cubit.removeFile(file),
                                  icon: Icon(Icons.close),
                                ),
                              );
                            },
                          )
                        : CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverFillRemaining(
                                child: Center(child: Text("No files selected")),
                              ),
                            ],
                          ),
                  ),
                  LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    value: state.isLoadingFiles ? null : 1,
                    minHeight: 1,
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: state.isLoadingFiles
                                  ? null
                                  : _cubit.startSession,
                              child: Text("Send"),
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton.outlined(
                            onPressed: state.isLoadingFiles
                                ? null
                                : _cubit.addFiles,
                            icon: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
