import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/sender.dart';
import 'package:nice_share/core/services/find_senders/find_senders_cubit.dart';

class ReceiveFilesDialog extends StatefulWidget {
  const ReceiveFilesDialog._();

  @override
  State<ReceiveFilesDialog> createState() => _ReceiveFilesDialogState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => ReceiveFilesDialog._(),
    );
  }
}

class _ReceiveFilesDialogState extends State<ReceiveFilesDialog> {
  final _cubit = FindSendersCubit();

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
              child: Text("Senders", style: TextStyle(fontWeight: .bold)),
            ),
          ),
          BlocBuilder<FindSendersCubit, List<Sender>>(
            bloc: _cubit,
            builder: (context, state) {
              return Expanded(
                child: state.isNotEmpty
                    ? ListView.separated(
                        itemCount: state.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final sender = state[index];
                          return ListTile(
                            title: Text(
                              "0x${sender.sessionId.toRadixString(16)}",
                            ),
                          );
                        },
                      )
                    : Center(child: Text("Empty")),
              );
            },
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
