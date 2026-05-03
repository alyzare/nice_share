import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/services/find_senders/find_senders_cubit.dart';

class ReceiveFiles extends StatefulWidget {
  const ReceiveFiles._();

  @override
  State<ReceiveFiles> createState() => _ReceiveFilesState();

  static Future<void> show(BuildContext context) {
    return Platform.isAndroid
        ? showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ReceiveFiles._(),
          )
        : showDialog(context: context, builder: (context) => ReceiveFiles._());
  }
}

class _ReceiveFilesState extends State<ReceiveFiles> {
  late final _cubit = FindSendersCubit(sessionsCubit: context.read());

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: Center(
            child: Text("Senders", style: TextStyle(fontWeight: .bold)),
          ),
        ),
        BlocBuilder<FindSendersCubit, Map<Sender, SenderStatus>>(
          bloc: _cubit,
          builder: (context, state) {
            final entries = state.entries.toList();
            return Expanded(
              child: state.isNotEmpty
                  ? ListView.separated(
                      itemCount: state.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return ListTile(
                          onTap: entry.value.canRequest
                              ? () => _cubit.sessionSelected(entry.key)
                              : null,
                          title: Text(
                            "0x${entry.key.sessionId.toRadixString(16)} : ${entry.key.address}",
                          ),
                          leading: entry.value.canRequest
                              ? SizedBox.shrink()
                              : entry.value == .asking
                              ? CircularProgressIndicator()
                              : Icon(
                                  Icons.done_outline_rounded,
                                  color: Colors.green,
                                ),
                        );
                      },
                    )
                  : Center(child: Text("Empty")),
            );
          },
        ),
      ],
    );
    return Platform.isAndroid
        ? DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceBright,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: content,
              );
            },
          )
        : Dialog(
            constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
            clipBehavior: .antiAlias,
            child: content,
          );
  }
}
