import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';

class SessionsDialog extends StatefulWidget {
  const SessionsDialog._();

  @override
  State<SessionsDialog> createState() => _SessionsDialogState();

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SessionsDialog._(),
    );
  }
}

class _SessionsDialogState extends State<SessionsDialog> {
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
              child: Text("Sessions", style: TextStyle(fontWeight: .bold)),
            ),
          ),
          BlocBuilder<SessionsCubit, SessionsState>(
            builder: (context, state) {
              final sessions = state.sessions;
              return Expanded(
                child: sessions.isNotEmpty
                    ? ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return ListTile(
                            title: Text("Session ${index + 1}"),
                            trailing: IconButton(
                              onPressed: () => context.read<SessionsCubit>().stopSession(session),
                              icon: Icon(Icons.stop_rounded),
                            ),
                          );
                        },
                      )
                    : Center(child: Text("Empty")),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ).copyWith(bottom: 8),
            child: FilledButton(onPressed: () {}, child: Text("Stop all")),
          ),
        ],
      ),
    );
  }
}
