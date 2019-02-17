import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:learnspace/file_model.dart';

class DeviceModel {
  String name;
  int type;
  Color color;
  String device_id;

  DeviceModel(this.name, this.type, this.color, this.device_id);

  DeviceModel.fromJson(Map<String, dynamic> json)
      : type = json['device_type'],
        name = json['nickname'],
        color = Color(int.parse(json['color'], radix: 16));
}


class DeviceInfo {
  String desc;
  int device_type;
  String nickname;

  DeviceInfo(this.desc, this.device_type, this.nickname);

  Map<String, dynamic> toJson() =>
      {
        'desc': desc,
        'device_type': device_type,
        'nickname': nickname
      };
}

List<DeviceModel> MyDevices = [];
List<DeviceFile> OpenedFiles = [];

String Addr = "hacknyu.yuuno.cc";
String ServerAddr = "http://${Addr}:3000";

SocketIO socketIO;

BuildContext MainRouterContext = null;
String MyID;