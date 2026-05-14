import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

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

Future<Directory?> getDownloadDirectory() async => Platform.isAndroid
    ? Directory("/storage/emulated/0")
    : await getDownloadsDirectory();

Future<List<InternetAddress>> myIps() async {
  return NetworkInterface.list().then(
    (list) => list
        .map(
          (i) => i.addresses.firstWhere(
            (element) => element.type == .IPv4 && !element.isLoopback,
          ),
        )
        .toList(),
  );
}

int _messageCounter = 1;
int _sessionCounter = 1;

int get newMessageId => _messageCounter++;

int get newSessionId => _sessionCounter++;
