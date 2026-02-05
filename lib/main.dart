import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/services/sessions/sessions_cubit.dart';
import 'package:nice_share/nice_share_app.dart';

void main() {
  runApp(
    BlocProvider(create: (context) => SessionsCubit(), child: NiceShareApp()),
  );
}
