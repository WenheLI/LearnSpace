import 'package:flutter/material.dart';

class DeviceModel {
  String name;
  int type;
  Color color;

  DeviceModel(this.name, this.type, this.color);
}

List<DeviceModel> MyDevices = [];