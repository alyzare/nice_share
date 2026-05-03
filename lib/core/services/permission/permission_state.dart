part of 'permission_cubit.dart';

enum PermissionState {
  asking(null),
  granted(true),
  denied(false);

  final bool? status;

  const PermissionState(this.status);
}
