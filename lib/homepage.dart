import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learnspace/file_list.dart';
import 'package:learnspace/file_model.dart';
import 'package:learnspace/view_pdf.dart';
import 'package:learnspace/view_text.dart';
import 'package:learnspace/store.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    MainRouterContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Learn Space"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 12.0, left: 4.0),
            child: GestureDetector(

              onTap: ()  {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileList()),
                );
              },

              child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(OpenedFiles.length.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  )
              ),
            ),
          )
        ],
      ),
      body: InfiniteListView(),
    );
  }

}

class InfiniteListView extends StatefulWidget {
  @override
  _InfiniteListViewState createState() => new _InfiniteListViewState();

}

class _InfiniteListViewState extends State<InfiniteListView> {
  var _files = <List<DeviceFile>>[];
  List<String> _types = ["pdf", "txt"];

  @override
  void initState() {
    _retrieveData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _files.length,
      itemBuilder: (context, index) {
            return StickyHeader(
              header:  Material(
                color: Colors.grey.shade200,
                child: Container(
                  color: Colors.transparent,
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
                  child: Flex(
                    children: <Widget>[
                      Expanded(child: Text(_types[index].toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54))),
                      IconButton(
                        icon: Icon(Icons.sort),
                        iconSize: 32,
                        onPressed: () {
                          debugPrint("clicl");
                        },)
                    ],
                    direction: Axis.horizontal,
                  )
                ),
              ),
              content: DisplayRow(this._files[index])
            );
          }
        );

  }

  void _retrieveData() async {
      var temp = List<List<DeviceFile>>();
      String pdfPath = "";

      if (Platform.isAndroid) {
        bool ok = await SimplePermissions.checkPermission(
            Permission.WriteExternalStorage);
        if (!ok) {
          await SimplePermissions.requestPermission(
              Permission.WriteExternalStorage);
        }
        pdfPath = "/sdcard/Download/";
      } else {
        pdfPath = (await getApplicationDocumentsDirectory()).path;
      }
      List<String> files = Directory
        .fromUri(Uri.file(pdfPath))
        .listSync(recursive: true, followLinks: false)
        .map((f) => f.path).toList();

      _types.forEach((ext) {
        temp.add(files
          .where((f) => f.endsWith(ext))
          .map((f) => DeviceFile(f.split("/")[f.split("/").length - 1], ext, "", f))
          .toList());
      });

      print(temp);

      setState(() {
        _files = temp;
      });
  }
}

class DisplayRow extends StatelessWidget {
  List<DeviceFile> _files;

  DisplayRow(this._files);

  getElements(files) {
    var res = List<Widget>();
    for (var file in this._files) {
      res.add(
          Displayer(file)
      );
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.start,
          children:
            getElements(_files)

    );
  }
}

class Displayer extends StatelessWidget {
  DeviceFile _file;

  Displayer(this._file);

  @override
  Widget build(BuildContext context) {

    String imageFile = _file.type + ".png";
    return  GestureDetector(
      onTap:() {
        OpenedFiles.add(_file);
        if (_file.type == 'pdf') Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewPDF(_file)));
        else Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewText(_file)));
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Image(
              image: NetworkImage("$ServerAddr/$imageFile"),
              width: 140.0,
            ),
            FuncBar(_file)
          ],
        ),
      ),
    );
  }
  
}

class FuncBar extends StatelessWidget {

  DeviceFile myfile;

  FuncBar(this.myfile);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 0)
                )
              ]
          ),
          width: MediaQuery.of(context).size.width / 2 - 4.0,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Image(
                  image: AssetImage("assets/${myfile.type}.png"),
                  width: 25,
                  height: 25,
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(myfile.title, style: TextStyle(decorationStyle: TextDecorationStyle.dotted), maxLines: 1,),
              ),
              Expanded(
                flex: 2,
                child: IconButton(icon: Icon(Icons.more_vert), onPressed: () => debugPrint("Pressed")),
              ),
            ],
          )
      ),
    );
  }
}