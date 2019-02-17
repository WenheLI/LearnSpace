import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnspace/file_model.dart';
import 'package:learnspace/homepage.dart';
import 'package:learnspace/file_list.dart';
import 'package:learnspace/store.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//
//    Dio().get(ServerAddr+'/devices').then((e)  {
//      (e.data as List).forEach((f){
//
//      });
//
//    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      title: 'LearnSpace',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
    );
  }
}


