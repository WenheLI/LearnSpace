import 'dart:io';

import 'dart:async';
import 'package:learnspace/file_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_plugin.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:dio/dio.dart';

class ViewText extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ViewTextState();

}

class _ViewTextState extends State<ViewText>{

  String filePath = "";

  @override
  void initState() {
    _getTxt();
  }

  @override
  Widget build(BuildContext context) {

    AppBar appBar = AppBar(
      iconTheme: IconThemeData(color: Colors.grey.shade800),
      backgroundColor: Colors.grey.shade300,
      title: Text("txt", style: TextStyle(color: Colors.grey.shade800)),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 4.0),
          child: GestureDetector(

            onTap: ()  {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FileList()),
              );
            },

            child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade800, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text("1", style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold),),
                )
            ),
          ),
        ),
        IconButton(icon: Icon(Icons.more_vert, color: Colors.grey.shade800), iconSize: 32, onPressed: () => debugPrint("pressed"),)
      ],
    );

    return Scaffold(appBar: appBar, body: _getProgress(),);
  }

  void _getTxt() async {
    await Future.delayed(Duration(seconds: 2));
    String p =  (await getApplicationDocumentsDirectory()).path;
    await Dio().download("http://10.18.67.245:3000/uploads/a.txt", p+'/a.txt');
    setState(() {
      this.filePath = p + '/C.txt';
      print(filePath);
    });
  }

  Widget _getProgress() {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Container(
          alignment: Alignment.center,
          child: SizedBox(child: CircularProgressIndicator(strokeWidth: 6), height: 120, width: 120,)
      ),
    );
  }

}