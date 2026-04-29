import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/choose_file/select_files_cubit.dart';
import 'package:nice_share/core/utils.dart';
import 'package:path/path.dart' as path;

class SelectFiles extends StatefulWidget {
  final bool isWeb;
  final SelectFilesVariant variant;

  const SelectFiles._({required this.variant, this.isWeb = false});

  static Future<void> show(BuildContext context, {bool isWeb = false}) {
    return Platform.isAndroid
        ? showDialog(
            context: context,
            builder: (_) => SelectFiles._(variant: .dialog, isWeb: isWeb),
          )
        : showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SelectFiles._(variant: .bottomSheet, isWeb: isWeb),
          );
  }

  @override
  State<SelectFiles> createState() => _SelectFilesState();
}

class _SelectFilesState extends State<SelectFiles> {
  late final _cubit = SelectFilesCubit(context.read(), widget.isWeb);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<SelectFilesCubit, SelectFileState>(
      bloc: _cubit,
      listenWhen: (_, current) => current is SessionCreated,
      listener: (_, state) {
        if (state is SessionCreated) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final list = state.files.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.files.length + (state is LoadingFiles ? 1 : 0),
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  if (state is LoadingFiles && index == state.files.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final file = state.files[index];
                  return ListTile(
                    title: Text(path.basename(file.path)),
                    subtitle: Text(formattedSize(file.lengthSync())),
                    trailing: IconButton(
                      onPressed: () => _cubit.removeFile(file),
                      icon: const Icon(Icons.close),
                    ),
                  );
                },
              )
            : Center(
                child: state is LoadingFiles
                    ? const CircularProgressIndicator()
                    : const Text("No files selected"),
              );

        return Column(
          children: [
            _Header(widget.variant),
            Expanded(child: list),
            LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              value: state.isLoadingFiles ? null : 1,
              minHeight: 1,
            ),
            _Actions(
              isLoading: state.isLoadingFiles,
              cubit: _cubit,
              variant: widget.variant,
            ),
          ],
        );
      },
    );

    if (widget.variant == SelectFilesVariant.dialog) {
      return Dialog(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    // Bottom sheet
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: content,
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final SelectFilesVariant variant;

  const _Header(this.variant);

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      .dialog => SizedBox(
        height: 40,
        child: Center(
          child: Text(
            "Select files to send",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      .bottomSheet => Column(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    };
  }
}

class _Actions extends StatelessWidget {
  final bool isLoading;
  final SelectFilesCubit cubit;

  final SelectFilesVariant variant;

  const _Actions({
    required this.isLoading,
    required this.cubit,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: variant == SelectFilesVariant.dialog
            ? const EdgeInsets.fromLTRB(12, 8, 12, 12)
            : const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: variant == SelectFilesVariant.dialog
              ? Border(top: BorderSide(color: Theme.of(context).dividerColor))
              : null,
        ),
        child: content,
      ),
    );
  }
}

enum SelectFilesVariant { dialog, bottomSheet }
