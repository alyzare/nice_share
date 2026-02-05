import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              OutlinedButton(onPressed: () {}, child: Text("Send")),
              OutlinedButton(onPressed: () {}, child: Text("Send via web")),
              OutlinedButton(onPressed: () {}, child: Text("Receive")),
            ],
          ),
        ),
      ),
    );
  }
}
