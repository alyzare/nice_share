import 'dart:io';

import 'package:path_provider/path_provider.dart';

sealed class Helper {
  static Future<Directory?> get downloadDirectory async => Platform.isAndroid
      ? Directory("/storage/emulated/0")
      : await getDownloadsDirectory();

  static Stream<List<InternetAddress>> get localIpStream =>
      Stream.periodic(Duration(seconds: 1)).asyncMap((_) async {
        final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4,
          includeLoopback: false,
        );

        return interfaces.expand((i) => i.addresses).toList();
      });

  static String formattedSize(int size) {
    for (final unit in ["B", "KB", "MB", "GB"]) {
      if (size < 1024) {
        return "${size.toStringAsFixed(2)} $unit";
      }
      size ~/= 1024;
    }
    return "${size.toStringAsFixed(2)} TB";
  }

  static String updateCssVariables(
    String cssString,
    Map<String, dynamic> variables,
  ) {
    // Pattern to find :root block
    final rootPattern = RegExp(r':root\s*\{([^}]*)\}', dotAll: true);

    // Check if :root exists
    if (rootPattern.hasMatch(cssString)) {
      // Get the current :root content
      final match = rootPattern.firstMatch(cssString)!;
      final currentRootContent = match.group(1)!;

      // Update existing variables or add new ones
      String updatedRootContent = currentRootContent;

      for (var entry in variables.entries) {
        final varName = entry.key;
        final varValue = entry.value.toString();

        // Pattern to find specific CSS variable in the root content
        final varPattern = RegExp(
          r'--' + RegExp.escape(varName) + r'\s*:\s*[^;]+;',
        );

        final variableDeclaration = '--$varName: $varValue;';

        if (varPattern.hasMatch(updatedRootContent)) {
          // Replace existing variable
          updatedRootContent = updatedRootContent.replaceAllMapped(
            varPattern,
            (_) => variableDeclaration,
          );
        } else {
          // Add new variable at the end of root content
          updatedRootContent = updatedRootContent.trimRight();
          if (!updatedRootContent.endsWith(';')) {
            updatedRootContent += ';';
          }
          updatedRootContent += ' $variableDeclaration';
        }
      }

      // Replace the entire :root block
      return cssString.replaceFirst(rootPattern, ':root{$updatedRootContent}');
    } else {
      // :root doesn't exist, create it at the beginning of the CSS
      final rootBlock = StringBuffer(':root{');

      for (var entry in variables.entries) {
        rootBlock.write('--${entry.key}: ${entry.value};');
      }
      rootBlock.write('}');

      return '${rootBlock.toString()}\n$cssString';
    }
  }

  Helper._();
}
