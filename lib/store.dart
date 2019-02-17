import 'package:flutter/material.dart';
import 'package:learnspace/file_model.dart';

class DeviceModel {
  String name;
  int type;
  Color color;

  DeviceModel(this.name, this.type, this.color);

  DeviceModel.fromJson(Map<String, dynamic> json)
      : type = json['device_type'],
        name = json['nickname'],
        color = Color(int.parse(json['color'], radix: 16));
}

List<DeviceModel> MyDevices = [];
List<DeviceFile> OpenedFiles = [];
String ServerAddr = "http://10.18.67.245:3000";
