import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/features/home/presentation/components/select_files_dialog.dart';
import 'package:nice_share/features/home/presentation/components/sessions_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Nice Share"),
        leading: BlocBuilder<SessionsCubit, SessionsState>(
          builder: (_, state) {
            return IconButton(
              onPressed: state.sendSessions.isEmpty
                  ? null
                  : () => SessionsDialog.show(context),
              icon: state.sendSessions.isEmpty
                  ? SizedBox.shrink()
                  : Text(state.sendSessions.length.toString()),
            );
          },
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              OutlinedButton(
                onPressed: () {
                  SelectFilesDialog.show(context);
                },
                child: Text("Send"),
              ),
              OutlinedButton(onPressed: () {}, child: Text("Send via web")),
              OutlinedButton(onPressed: () {}, child: Text("Receive")),
            ],
          ),
        ),
      ),
    );
  }
}
