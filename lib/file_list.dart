import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';
import 'package:learnspace/store.dart';
import 'package:learnspace/file_model.dart';

class FileList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(1, 0, 0, 0),
        actions: <Widget>[
          FlatButton(
            padding: EdgeInsets.all(0),
            shape: CircleBorder(),
            onPressed: () {debugPrint("OK");},
            child: Icon(Icons.more_vert, color: Colors.black54)
          )
        ],
        leading: FlatButton(
          shape: CircleBorder(),
          child: Icon(Icons.add, color: Colors.black54),
          onPressed: () {debugPrint("OK");},
        ),
      ),
      body: WindowListViewer(),
    );
  }
}

class WindowListViewer extends StatefulWidget {
  @override
  _WindowListViewerState createState() => new _WindowListViewerState();
}

class _WindowListViewerState extends State<WindowListViewer> with SingleTickerProviderStateMixin {

  List<Widget> _windows = [];
  List<Widget> _devices = [];

  List<Widget> _machine = [];
  List<Widget> _content = [];

  List<GlobalKey> _keyOfDevices = [];

  double _yOffset = 350;
  double _maxHeight = 150;
  double _dragUpdateStartAt = 0;
  double _dragUpdateStartOffset = 0;

  double _singleDragStartX = 0;
  double _singleDragStartY = 0;

  int _currentFocusedDevice = -1;
  int _currentFocused = -1;

  Animation<double> animation;
  AnimationController controller;

  List _devicesNames = ['Mac', 'iPad'];
  List _devicesTypes = [2, 1];
  List _devicesColor = [Colors.amber, Colors.blue];

  BuildContext _ctx;

  @override
  void initState() {
    _generateWindows();
    _adjustWindows(999999);

    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween(begin: -90.0, end: 0.0,).chain(
        CurveTween(
          curve: Curves.ease,
        )
    ).animate(controller)
    ..addListener(() {
      setState(()=>{});
    });

  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  double _computeOffset(int i) {
    int n = _content.length;
    if (n <= 1) return 0;
    int anchor = n - _yOffset ~/ _maxHeight - 2;
    double fold = _yOffset - (n - anchor - 2) * _maxHeight;
    if (i > anchor) {
      return 2.0 * anchor + fold + (i - anchor - 1) * _maxHeight;
    } else {
      return 2.0 * i;
    }
  }

  void _finishSend() {
    _updateDevicesState(success: _currentFocusedDevice);
    final snackBar = SnackBar(
      content: Text("Upload to Device: " + _devicesNames[_currentFocusedDevice]),
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: () {},
      ),
    );
    Scaffold.of(_ctx).showSnackBar(snackBar);
    _currentFocused = -1;
    controller.reverse();
  }

  Transform _CardWrapper(int i, WindowItem f, {double dx=0, double dy=0, double scale=1, bool opacity=false}) {
    double _s = scale > 1 ? 1.0 : scale;
    return Transform.translate(
      offset: Offset(dx, dy + 16.0 + _computeOffset(i)),
      child: GestureDetector(
        child: Transform.scale(scale: _s, child: Opacity(opacity: opacity ? 0.7 : 1, child: Container(
            decoration: BoxDecoration(color: Colors.black.withAlpha(200), borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Opacity(opacity: opacity ? 0.5 : 1, child: f),
          ),),
        ),
        onLongPressDragStart: (GestureLongPressDragStartDetails details) {
          _singleDragStartX = details.globalPosition.dx;
          _singleDragStartY = details.globalPosition.dy;
          _currentFocused = i;
          controller.forward();
        },
        onLongPressDragUp: (GestureLongPressDragUpDetails details) {
          if (_currentFocusedDevice >= 0) {
            final RenderBox rdBox = _keyOfDevices[_currentFocusedDevice].currentContext.findRenderObject();
            final double x = rdBox.localToGlobal(Offset.zero).dx;
            final double y = rdBox.localToGlobal(Offset.zero).dy;

            final double currentDx = details.globalPosition.dx - _singleDragStartX;
            final double currentDy = details.globalPosition.dy - _singleDragStartY;
            final double targetDx = x + 34 - _singleDragStartX;
            final double targetDy = y + 34 - _singleDragStartY;
            final double stepX = targetDx - currentDx;
            final double stepY = targetDy - currentDy;

            for (int i = 0; i < 10; i ++) {
              final int d = i;
              Future.delayed(Duration(milliseconds: 20 * d), () {
                _adjustWindows(_yOffset, dx: currentDx + stepX * d, dy: currentDy + stepY * d, scale: i == 9 ? 0.0 : 0.8 / i);
              });
              _updateDevicesState(progress: _currentFocusedDevice);
            }

            Future.delayed(Duration(seconds: 5), () {
              _finishSend();
            });

          } else {
            _currentFocused = -2;
            _adjustWindows(_yOffset);
            _currentFocused = -1;
            controller.reverse();
          }

        },
        onLongPressDragUpdate: (GestureLongPressDragUpdateDetails details) {
          int _tmpFocusedDevice = -1;
          for (int i = 0; i < 2; i++) {
            final RenderBox rdBox = _keyOfDevices[i].currentContext.findRenderObject();
            final double x = rdBox.localToGlobal(Offset.zero).dx;
            final double y = rdBox.localToGlobal(Offset.zero).dy;
            if (details.globalPosition.dx > x - 5 && details.globalPosition.dx < x + 68 + 5 &&
                details.globalPosition.dy > y - 5 && details.globalPosition.dy < y + 90 + 5) {
              _tmpFocusedDevice = i;
              break;
            }
          }
          if (_tmpFocusedDevice != _currentFocusedDevice) {
            _currentFocusedDevice = _tmpFocusedDevice;
            _updateDevicesState();
            if (_currentFocusedDevice >= 0) {
              Vibrate.feedback(FeedbackType.light);
            }
          }
          _adjustWindows(_yOffset, dx: details.globalPosition.dx - _singleDragStartX, dy: details.globalPosition.dy - _singleDragStartY);
        },
      ),
    );
  }

  void _adjustWindows(double yOffset, {double dx=0, double dy=0, double scale=0.96}) {
    if (yOffset == _yOffset && _currentFocused == -1) return;
    _yOffset = yOffset;
    if (_yOffset < 0) _yOffset = 0;
    else if (_yOffset > (_content.length-1) * _maxHeight) _yOffset = (_content.length-1) * _maxHeight;
    setState(() {
      int i = 0;
      _windows = _content.map((f) {
        if (i == _currentFocused) return _CardWrapper(i++, f, dx: dx, dy: dy, scale: scale, opacity: true);
        else return _CardWrapper(i++, f);
      }).toList();
      if (_currentFocused >= 0) {
        Transform t = _windows[_currentFocused];
        _windows.removeAt(_currentFocused);
        _windows.add(t);
      }
    });
  }

  void _generateWindows() {
    OpenedFiles.forEach((f) {
      _content.add(WindowItem(f));
    });

    [0,1].forEach((i) {
      _machine.add(DeviceItem(_devicesNames[i], _devicesTypes[i], _devicesColor[i], 0));
    });

    _updateDevicesState();
  }

  void _updateDevicesState({int progress: -1, int success: -1}) {
    int i = 0;
    if (progress != -1) _machine[progress] = DeviceItem(_devicesNames[progress], _devicesTypes[progress], _devicesColor[progress], 1);
    else if (success != -1) _machine[success] = DeviceItem(_devicesNames[success], _devicesTypes[success], _devicesColor[success], 0);
    setState(() {
      _keyOfDevices = List(2).map((f) => GlobalKey()).toList();
      _devices = _machine.map((f) {
        i++;
        return Opacity(key: _keyOfDevices[i-1], child: f, opacity: i-1 == _currentFocusedDevice ? 1.0 : 0.5);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    _ctx = context;
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Padding(
        padding: EdgeInsets.only(top: 0),
        child: GestureDetector(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: _windows
              ),
              Stack(
                alignment: Alignment.centerRight,
                children: [Positioned(child: Opacity(child: Column(children: _devices), opacity: (animation.value + 90.0) / 90.0,), right: animation.value + 16.0)],
              ),
            ]
          ),
          onVerticalDragUpdate: (DragUpdateDetails details) {
            _adjustWindows(_dragUpdateStartOffset + details.globalPosition.dy - _dragUpdateStartAt);
          },
          onVerticalDragStart: (DragStartDetails details) {
            _dragUpdateStartAt = details.globalPosition.dy;
            _dragUpdateStartOffset = _yOffset;
          },
          onVerticalDragEnd: (DragEndDetails details) {
            int delta = details.velocity.pixelsPerSecond.dy ~/ 150;
            int thrd = delta ~/ 10;
            int step = 0;
            for (int i = 0; i < 10; i ++) {
              step++;
              final int myDelta = delta;
              Future.delayed(Duration(milliseconds: 20 * step), () {
                _adjustWindows(_yOffset + myDelta);
              });
              delta -= thrd;
            }
          },
        ),
      ),
    );
  }

}

class WindowItem extends StatelessWidget {

  DeviceFile _file;

  WindowItem(_file);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0)), boxShadow: <BoxShadow>[BoxShadow(color: Color.fromARGB(25, 0, 0, 0), offset: Offset(5, 5), blurRadius: 5, spreadRadius: 5)]),
      width: MediaQuery.of(context).size.width - 36,
      height: MediaQuery.of(context).size.width * 1.6,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(_file.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)),
                IconButton(icon: Icon(Icons.cancel, size: 18), onPressed: null)
              ]
            )
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 6),
              child: Container(
                decoration: BoxDecoration(color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(6.0))),
                child: Image(
                  image: NetworkImage("$ServerAddr/${_file.type}.png"),
                  width: 140.0,
                ),
              )
            )
          )
        ]
      )
    );
  }
}

class DeviceItem extends StatelessWidget {

  String name;
  Color color;
  int type;
  int state;

  DeviceItem(@required this.name, @required this.type, @required this.color, @required this.state);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 116,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(64), color: color, boxShadow: <BoxShadow>[BoxShadow(color: Color.fromARGB(25, 0, 0, 0), offset: Offset(2, 2), blurRadius: 2, spreadRadius: 2)]),
            child: Center(child:
              state == 0 ? Icon(type == 0 ? Icons.phone_iphone : (type == 1 ? Icons.tablet_mac : Icons.laptop_mac), color: Colors.white,)
                  : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              width: 64,
              height: 20,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(64), color: color, boxShadow: <BoxShadow>[BoxShadow(color: Color.fromARGB(25, 0, 0, 0), offset: Offset(2, 2), blurRadius: 2, spreadRadius: 2)]),
              child: Center(child: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))
            ),
          )
        ]
      ),
    );
  }
}