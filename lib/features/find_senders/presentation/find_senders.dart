import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/features/find_senders/logic/find_senders_cubit.dart';

class FindSenders extends StatefulWidget {
  const FindSenders._();

  @override
  State<FindSenders> createState() => _FindSendersState();

  static Future<void> show(BuildContext context) {
    return Platform.isAndroid
        ? showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => FindSenders._(),
          )
        : showDialog(context: context, builder: (context) => FindSenders._());
  }
}

class _FindSendersState extends State<FindSenders> {
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
                          title: Row(
                            mainAxisSize: .min,
                            spacing: 10,
                            children: [
                              Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                child: Center(
                                  child: Text(
                                    entry.key.peerName ??
                                        "[${entry.key.address.address}]",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              Text("Session: ${entry.key.sessionId}"),
                            ],
                          ),

                          trailing: entry.value.canRequest
                              ? SizedBox.shrink()
                              : entry.value == .asking
                              ? SizedBox.square(
                                  dimension: 25,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(128),
                                    strokeCap: .round,
                                    strokeWidth: 7.5,
                                  ),
                                )
                              : Icon(
                                  Icons.done_rounded,
                                  color: Colors.green,
                                  size: 30,
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
