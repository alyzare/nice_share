import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nice_share/core/helper.dart';
import 'package:path/path.dart' as path;

import '../logic/select_files_cubit.dart';

class SelectFiles extends StatelessWidget {
  const SelectFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectFilesCubit, SelectFileState>(
      listenWhen: (_, current) => current is SessionCreated,
      listener: (_, state) {
        if (state is SessionCreated) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _Header(),
                  state.files.isNotEmpty
                      ? SliverList.builder(
                          itemCount:
                              state.files.length +
                              (state is LoadingFiles ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (state is LoadingFiles &&
                                index == state.files.length) {
                              return Center(
                                child: LoadingAnimationWidget.progressiveDots(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  size: 20,
                                ),
                              );
                            }

                            final file = state.files[index];
                            return ListTile(
                              title: Text(path.basename(file.path)),
                              subtitle: Text(
                                Helper.formattedSize(file.lengthSync()),
                              ),
                              trailing: IconButton(
                                onPressed: () => context
                                    .read<SelectFilesCubit>()
                                    .removeFile(file),
                                icon: const Icon(Icons.close),
                              ),
                            );
                          },
                        )
                      : SliverFillRemaining(
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
            _Actions(isLoading: state.isLoadingFiles),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? SliverAppBar(
            pinned: true,
            leading: SizedBox.shrink(),
            shape: RoundedRectangleBorder(
              borderRadius: .vertical(top: Radius.circular(25)),
            ),
            flexibleSpace: Column(
              mainAxisAlignment: .spaceEvenly,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Text(
                  'Select files to send',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        : SizedBox(
            height: 40,
            child: Center(
              child: Text(
                "Select files to send",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
  }
}

class _Actions extends StatelessWidget {
  final bool isLoading;

  const _Actions({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SelectFilesCubit>();
    final content = Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: isLoading ? null : cubit.startSession,
            child: const Text("Send"),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.outlined(
          onPressed: isLoading ? null : cubit.addFiles,
          icon: const Icon(Icons.add),
        ),
      ],
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: !Platform.isAndroid
            ? const EdgeInsets.fromLTRB(12, 8, 12, 12)
            : const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: !Platform.isAndroid
              ? Border(top: BorderSide(color: Theme.of(context).dividerColor))
              : null,
        ),
        child: content,
      ),
    );
  }
}
