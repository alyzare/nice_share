import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/features/find_senders/logic/find_senders_cubit.dart';

class FindSenders extends StatelessWidget {
  const FindSenders({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: Center(
            child: Text("Senders", style: TextStyle(fontWeight: .bold)),
          ),
        ),
        BlocBuilder<FindSendersCubit, Map<Sender, SenderStatus>>(
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
                              ? () => context
                                    .read<FindSendersCubit>()
                                    .sessionSelected(entry.key)
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
  }
}
