import 'dart:io';

import 'dart:async';
import 'package:learnspace/file_list.dart';
import 'package:learnspace/store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_plugin.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:learnspace/file_model.dart';
import 'package:simple_permissions/simple_permissions.dart';

class ViewText extends StatefulWidget {

  DeviceFile file;
  ViewText(this.file);

  @override
  State<StatefulWidget> createState() => _ViewTextState(file);

}

class _ViewTextState extends State<ViewText>{

  DeviceFile file;
  String filePath = "";
  String fileData = "";

  int _cursor = -1;
  bool _isUpdated = false;

  final myController = new TextEditingController();
  _ViewTextState(this.file);

  @override
  void initState() {
    _getTxt();
  }

  @override
  Widget build(BuildContext context) {

    AppBar appBar = AppBar(
      iconTheme: IconThemeData(color: Colors.grey.shade800),
      backgroundColor: Colors.grey.shade300,
      title: Text(file.title, style: TextStyle(color: Colors.grey.shade800)),
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
                  child: Text(OpenedFiles.length.toString(), style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold),),
                )
            ),
          ),
        ),
        IconButton(icon: Icon(Icons.more_vert, color: Colors.grey.shade800), iconSize: 32, onPressed: () => debugPrint("pressed"),)
      ],
    );

    return Scaffold(
        appBar: appBar,
        body: this.filePath.isEmpty ? _getProgress()
              : _getTxtView(this.filePath)
      );
  }

  void _getTxt() async {
    print(file);
    print(filePath);
    String p = "";
    if (Platform.isAndroid) {
      bool ok = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
      if (!ok) {
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
      }
      p = "/sdcard/Download/";
    } else {
      p = (await getApplicationDocumentsDirectory()).path;
    }
    if (file == null) {
      await Dio().download(
          "http://10.18.67.245:3000/uploads/a.txt", p + '/a.txt');
      setState(() {
        this.filePath = p + '/a.txt';
        print(filePath);
      });
    } else {
      setState(() { this.filePath = file.filePath; });
      Future.delayed(Duration(milliseconds: 100), () async {
        File f = File.fromUri(Uri.file(file.filePath));
        myController.text = f.readAsStringSync();
        if (file.cursor != -1) {
          myController.selection = new TextSelection.fromPosition(
              new TextPosition(offset: file.cursor));
        }
      });
    }
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

  @override
  void dispose() {
    if (_isUpdated) {
      File f = File.fromUri(Uri.file(file.filePath));
      f.writeAsStringSync(myController.text);
      file.cursor = _cursor;
      debugPrint("Cursor At: " + _cursor.toString());
    }
    myController.dispose();
    super.dispose();
  }

  void _onChange(String text) {
    _isUpdated = true;
    _cursor = myController.selection.start;
  }

  void _onTap() {
    _isUpdated = true;
    _cursor = myController.selection.start;
  }

  Widget _getTxtView(String path) {
    return ConstrainedBox(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Please edit this file ~'),
        controller: myController,
        autofocus: true,
        autocorrect: true,
        onChanged: _onChange,
        onTap: _onTap,
        keyboardType: TextInputType.multiline,
        maxLines: 9999999,
      ),
      constraints: BoxConstraints.expand(),
    );
  }
}