import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/core/services/web_session/web_session_cubit.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionsCubit, int>(
      builder: (context, state) {
        final sessions = context.read<SessionsCubit>().sessions;
        return sessions.isNotEmpty
            ? ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    title: Text(
                      session is WebSessionCubit
                          ? "WebSession: ${session.sessionId}"
                          : "Session ${index + 1}",
                    ),
                    trailing: IconButton(
                      onPressed: session.close,
                      icon: Icon(Icons.stop_rounded),
                    ),
                  );
                },
              )
            : Center(child: Text("No sessions"));
      },
    );
  }
}
