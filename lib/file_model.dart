class DeviceFile {
  final String title;
  final String type;
  final String fileId;
  final String filePath;

  int cursor = -1;

  DeviceFile(this.title, this.type, this.fileId, this.filePath);
}