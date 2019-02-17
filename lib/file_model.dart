class DeviceFile {
  String title;
  String type;
  String fileId;
  String filePath;
  String url;

  int cursor = -1;

  DeviceFile(this.title, this.type, this.fileId, this.filePath, {this.url=""});
}