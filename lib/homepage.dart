import 'package:flutter/material.dart';
import 'package:learnspace/file_model.dart';
import 'package:learnspace/view_pdf.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learn Space"),
        actions: <Widget>[Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(Icons.search, size: 32),
        )],
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
  var _files = <List<File>>[];

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
                      Expanded(child: Text("Txt", style: TextStyle(fontSize: 24),)),
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

  void _retrieveData() {
      var temp = List<File>();
      setState(() {
        for(var i = 0; i < 10; i++) {
          temp.add(File("Hello " + i.toString(), "Type " + this._files.length.toString(), i.toString()));
        }
        _files.add(temp);
      });
  }
}

class DisplayRow extends StatelessWidget {
  var _files;

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
  var _file;

  Displayer(this._file);

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap:() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewPDF())),
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: <Widget>[
            Image(
              image: NetworkImage(
                  "https://avatars2.githubusercontent.com/u/20411648?s=460&v=4"),
              width: 140.0,
            ),
            FuncBar()
          ],
        ),
      ),
    );
  }
  
}

class FuncBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
          width: MediaQuery.of(context).size.width / 2 - 5.0,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image(
                  image: AssetImage("assets/pdf.png"),
                  width: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("hello"),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: IconButton(icon: Icon(Icons.more_vert), onPressed: () => debugPrint("Pressed")),
              ),
            ],
          )
      ),
    );
  }
}