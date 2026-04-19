import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  final Stream<String> logs;
  const LogPage({super.key, required this.logs});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final _logs = <String>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logs")),
      body: StreamBuilder(
        stream: widget.logs,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            _logs.add(asyncSnapshot.data!);
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return Text(_logs[index]);
            },
            itemCount: _logs.length,
          );
        },
      ),
    );
  }
}
