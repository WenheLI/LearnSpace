import 'dart:io';

import 'dart:async';
import 'package:learnspace/file_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_plugin.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:learnspace/file_model.dart';

class ViewPDF extends StatefulWidget {

  DeviceFile file;
  ViewPDF(this.file);

  @override
  State<StatefulWidget> createState() => _ViewPageState(file);
  
}

class _ViewPageState extends State<ViewPDF>{

  String filePath = "";
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

    return this.filePath.isEmpty ? Scaffold(appBar: appBar, body: _getProgress(),) : _getPdfView(appBar);
  }

  void _getPDF() async {
    if (file == null) {
        String p = (await getApplicationDocumentsDirectory()).path;
        await Dio().download(
            "http://10.18.67.245:3000/uploads/C.pdf", p + '/C.pdf');
        setState(() {
          this.filePath = p + '/C.pdf';
          print(filePath);
        });
    } else {
      this.filePath = file.filePath;
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
    return GestureDetector(
      onHorizontalDragUpdate: (details){
        debugPrint(details.globalPosition.toString());
      },
      onTap: () => debugPrint('213'),
      child: PDFViewerScaffold(
        appBar: appbar,
        path: this.filePath,
      ),
    );
  }
}