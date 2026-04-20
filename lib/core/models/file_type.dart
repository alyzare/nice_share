enum MyFileType {
  image("Images"),
  video("Videos"),
  audio("Audios"),
  document("Documents"),
  archive("Archives"),
  other("Others");

  final String dirName;
  const MyFileType(this.dirName);

  static MyFileType fromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return MyFileType.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
      case 'wmv':
        return MyFileType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'ogg':
        return MyFileType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
        return MyFileType.document;
      case 'zip':
      case 'rar':
      case '7z':
        return MyFileType.archive;
      default:
        return MyFileType.other;
    }
  }
}
