import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceName() async {
  final plugin = DeviceInfoPlugin();
  final info = await plugin.deviceInfo;
  switch (info.runtimeType) {
    case const (WindowsDeviceInfo):
      return info.data['userName'];
    case const (AndroidDeviceInfo):
      return "";
  }
  return "";
}

String formattedSize(int size) {
  for (final unit in ["B", "KB", "MB", "GB"]) {
    if (size < 1024) {
      return "${size.toStringAsFixed(2)} $unit";
    }
    size ~/= 1024;
  }
  return "${size.toStringAsFixed(2)} TB";
}
