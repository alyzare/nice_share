import 'package:nice_share/core/helper.dart';

class UploadPermissionRequest {
  final List<UploadFileModel> files;

  UploadPermissionRequest.fromList(List<Map<String, dynamic>> map)
    : files = map
          .map((e) => UploadFileModel(name: e["name"], size: e["size"]))
          .toList();

  List<Map<String, dynamic>> get toList =>
      files.map((e) => {"name": e.name, "size": e.size}).toList();
}

class UploadFileModel {
  final String name;
  final int size;

  UploadFileModel({required this.name, required this.size});

  String get formattedSize =>
      Helper.formattedSize(size);
}
