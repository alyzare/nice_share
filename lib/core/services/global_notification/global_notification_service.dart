import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/components/responsive_modal.dart';
import 'package:nice_share/core/models/permission_request.dart';
import 'package:nice_share/core/models/upload_permission_request.dart';
import 'package:nice_share/features/global_notifications/presentation/components/request_permission_modal.dart';
import 'package:nice_share/features/global_notifications/presentation/components/request_upload_permission_modal.dart';
import 'package:nice_share/features/sessions/logic/sessions_cubit.dart';

class GlobalNotificationService {
  final navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<PermissionRequest> permissionRequestsSub;
  late final StreamSubscription<UploadPermissionRequest>
  uploadPermissionRequestsSub;

  GlobalNotificationService() {
    init();
  }

  void init() async {
    await WidgetsBinding.instance.endOfFrame;

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final sessionsCubit = context.read<SessionsCubit>();
    permissionRequestsSub = sessionsCubit.permissionRequests.listen(
      _onPermission,
    );
    uploadPermissionRequestsSub = sessionsCubit.uploadPermissionRequests.listen(
      _onUploadPermission,
    );
  }

  Future<void> _onPermission(PermissionRequest request) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final sessionsCubit = context.read<SessionsCubit>();
    try {
      final answer =
          await context.showResponsiveModal(
            child: RequestPermissionModal(request: request),
          ) ??
          false;
      sessionsCubit.setPermission(request, answer);
    } catch (e) {
      debugPrint("$e");
      sessionsCubit.setPermission(request, false);
    }
  }

  Future<void> _onUploadPermission(UploadPermissionRequest request) async {
    final context = navigatorKey.currentState?.context;
    if (context == null) return;

    final sessionsCubit = context.read<SessionsCubit>();

    try {
      final answer =
          await context.showResponsiveModal<bool>(
            child: RequestUploadPermissionModal(request: request),
          ) ??
          false;
      sessionsCubit.setUploadPermission(request, answer);
    } catch (e) {
      debugPrint("$e");
      sessionsCubit.setUploadPermission(request, false);
    }
  }
}
