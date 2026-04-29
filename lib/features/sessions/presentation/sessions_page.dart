import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_model.dart';

import '../logic/sessions_cubit.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionsCubit, List<SessionModel>>(
      builder: (context, sessions) {
        return sessions.isNotEmpty
            ? ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    title: Text(session.toString()),
                    trailing: IconButton(
                      onPressed: () {}, //session.close,
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
