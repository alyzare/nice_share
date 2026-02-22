class InfoHandler {
  final Map<String, Object> _info;
  final Future<String?> Function([String? name]) _askPermission;

  InfoHandler({
    required Map<String, Object> info,
    required Future<String?> Function([String? name]) askPermission,
  }) : _info = info,
       _askPermission = askPermission;

  Future<Map<String, Object>?> getInfo([String? name]) async {
    final token = await _askPermission(name);
    return token == null ? null : {..._info, "token": token};
  }
}
