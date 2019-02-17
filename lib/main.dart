import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnspace/file_model.dart';
import 'package:learnspace/homepage.dart';
import 'package:learnspace/file_list.dart';
import 'package:learnspace/store.dart';
import  'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:learnspace/view_pdf.dart';
import 'package:learnspace/view_text.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    if (socketIO == null) {
      socketIO = SocketIOManager().createSocketIO(ServerAddr, '/');
      socketIO.init();

      socketIO.subscribe('popDevice', _onPop);

      socketIO.subscribe('pushDevice', _onPush);

      socketIO.subscribe('newFile', _onFile);

      socketIO.subscribe('yourID', (dynamic data) {
        MyID = data.toString();
        Dio().get(ServerAddr + '/devices').then((e) {
          (e.data as List).forEach((f) {
            if (MyID.compareTo(f['device_id'].toString()) == 0) return;
            if (f['nickname'].toString().isEmpty) return;
            MyDevices.add(DeviceModel(f['nickname'], f['device_type'],
                Color(int.parse(f['color'].toString().substring(1), radix: 16)), f['device_id']));
          });
        });
      });

      socketIO.connect();

      Future.delayed(Duration( milliseconds: 10)).then((e){
        socketIO.sendMessage('updateInfo', json.encode(DeviceInfo('Hello', 1, "iPad"
            ".p0[p0/${Random().nextInt(1000)}")).toString());
      });
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      title: 'LearnSpace',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
    );
  }

  _onPop(dynamic data) {
    print('pop');
    data = json.decode(data);
    print(MyDevices.length);
    var temp = -1;
    for (var index = 0; index < MyDevices.length; index ++) {
//      print(MyDevices[index].device_id);
      if (MyDevices[index].device_id.compareTo( data['device_id'].toString()) == 0) {
        temp = index;
      }
    }
    if (temp >= 0)
      MyDevices.removeAt(temp);
    print(MyDevices.length);


  }

  _onPush(dynamic data) {
    print('push');
    data = json.decode(data);
    print(MyDevices.length);
    MyDevices.add(DeviceModel(data['nickname'], data['device_type'], Color(int.parse(data['color'].toString().substring(1), radix: 16)), data['device_id']));
    print(MyDevices.length);
  }

  _onFile(dynamic data) {
    print("File incomes");
    final int cursor = int.parse(json.decode(data)['file_state']['cursor'].toString() ?? "-1");
    Dio().get(ServerAddr+'/file', queryParameters: {'file_id': json.decode(data)['file_id']}).then((e){

      var temp = e.data;
      var name = temp['file_name'];

      DeviceFile _file = DeviceFile(name, name.split(".")[name.split(".").length - 1], temp['file_id'], "", url: temp['file_path']);
      _file.cursor = cursor;
      OpenedFiles.add(_file);

      if (name.toString().endsWith('.pdf')) Navigator.of(MainRouterContext).push(MaterialPageRoute(builder: (_) => ViewPDF(_file)));
      else Navigator.of(MainRouterContext).push(MaterialPageRoute(builder: (_) => ViewText(_file)));

    });
  }
}


