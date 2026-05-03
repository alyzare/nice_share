import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/features/global_notifications/presentation/components/request_permission_dialog.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class GlobalNotifications extends InheritedWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  GlobalNotifications({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static GlobalNotifications of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlobalNotifications>()!;

  void init() {
    final sessionsCubit = navigatorKey.currentState?.context
        .read<SessionsCubit>();

    if (sessionsCubit == null) return;

    sessionsCubit.permissionRequests.listen(_onPermission);
  }

  Future<void> _onPermission(PermissionRequest request) async {
    final context = navigatorKey.currentState?.context;
    if (context == null) return;
    final sessionsCubit = context.read<SessionsCubit>();
    try {
      final answer =
          await RequestPermissionDialog.show(context, request) ?? false;
      sessionsCubit.setPermission(request, answer);
    } catch (e) {
      debugPrint("$e");
      sessionsCubit.setPermission(request, false);
    }
  }
}
