import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//6100ed
//7e39fbe
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
      body: InfiniteGridView(),
    );
  }

}

class InfiniteGridView extends StatefulWidget {
  @override
  _InfiniteGridViewState createState() => new _InfiniteGridViewState();
}

class _InfiniteGridViewState extends State<InfiniteGridView> {

  List<IconData> _icons = [];

  @override
  void initState() {
    _retrieveIcons();
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: _icons.length,
      itemBuilder: (BuildContext context, int index) {
        if (_icons.length - 1 == index && _icons.length < 200) {
          _retrieveIcons();
        }
        if (index % 21 == 0) {
          return Material(
              color: Colors.grey.shade200,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text("Txt",style: TextStyle(fontSize: 18),),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: InkWell(child: Icon(Icons.sort, size: 26,), onTap: ()=>debugPrint("heelo"),),
                    )
                  ],
                ),
          ));
        } else {
          return Displayer(_icons[index - (index ~/ 21) + 1]);
        }
      },
      staggeredTileBuilder: (int index) =>
      new StaggeredTile.count(index % 21 == 0 ? 4 : 2, index % 21 == 0 ? .5 : 1.8),
      mainAxisSpacing: 2.0,
      crossAxisSpacing: 2.0,
    );
  }

  void _retrieveIcons() {
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      setState(() {
        _icons.addAll([
          Icons.ac_unit,
          Icons.airport_shuttle,
          Icons.all_inclusive,
          Icons.beach_access, Icons.cake,
          Icons.free_breakfast
        ]);
      });
    });
  }
}

class Displayer extends StatelessWidget {

  IconData _icon;

  Displayer(this._icon);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        children: <Widget>[
          Expanded(
              child: FittedBox(
              fit: BoxFit.fill,
                child: Image(
                  image: NetworkImage(
                      "https://avatars2.githubusercontent.com/u/20411648?s=460&v=4"),
                  width: 100.0,
                )
              )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                  boxShadow: <BoxShadow>[
                    BoxShadow (
                      color: Colors.grey.shade300,
                      offset: new Offset(0.0, 2.0),
                      blurRadius: 2.0,
                    ),
                  ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4)
                )
              ),
              child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:const EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage("assets/pdf.png"),
                          width: 30,
                    )),
                   Expanded(child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text("Hello"),
                   )),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(this._icon),
                    )
                  ],
                )
            ),
          )
        ],
      ),
    );
  }
  
}