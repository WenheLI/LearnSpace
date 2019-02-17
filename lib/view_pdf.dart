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

class ViewPDF extends StatefulWidget {

  DeviceFile file;
  ViewPDF(this.file);

  @override
  State<StatefulWidget> createState() => _ViewPageState(file);
  
}

class _ViewPageState extends State<ViewPDF>{

  DeviceFile file;

  _ViewPageState(this.file);

  @override
  void initState() {
    _getPDF();
  }

  @override
  Widget build(BuildContext context) {

    AppBar appBar = AppBar(
      iconTheme: IconThemeData(color: Colors.grey.shade800),
      backgroundColor: Colors.grey.shade300,
      title: Text(file.title, style: TextStyle(color: Colors.grey.shade800)),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 22.0),
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
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(icon: Icon(Icons.more_vert, color: Colors.grey.shade800), iconSize: 32, onPressed: () => debugPrint("pressed"),),
        )
      ],
    );

    return file.filePath.isEmpty ? Scaffold(appBar: appBar, body: _getProgress(),) : _getPdfView(appBar);
  }

  void _getPDF() async {
    String p = "";
    if (Platform.isAndroid) {
      bool ok = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
      if (!ok) {
        await SimplePermissions.requestPermission(
            Permission.WriteExternalStorage);
      }
      p = "/sdcard/Download";
    } else {
      p = (await getApplicationDocumentsDirectory()).path;
    }
    if (file.filePath.isEmpty) {
        await Dio().download(
          ServerAddr + file.url, p + '/' + file.title);
        setState(() {
          file.filePath = p + '/' + file.title;
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

  Widget _getPdfView(AppBar appbar) {
    return PDFViewerScaffold(
        appBar: appbar,
        path: file.filePath,
      );
  }
}