import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _roomId = 'None';
  var mTextMessageController = new TextEditingController();
  SocketIO socketIO;
  SocketIO socketIO02;

  @override
  void initState() {
    super.initState();
  }

  _connectSocket01() {
    //update your domain before using
    /*socketIO = new SocketIO("http://127.0.0.1:3000", "/chat",
        query: "userId=21031", socketStatusCallback: _socketStatus);*/
    socketIO = SocketIOManager().createSocketIO("http://10.0.2.2:5000", "/user", query: "userId=21031", socketStatusCallback: _socketStatus);

    //call init socket before doing anything
    socketIO.init();

    //subscribe event
    socketIO.subscribe("socket_info", _onSocketInfo);

    //connect socket
    socketIO.connect();
  }

  _onSocketInfo(dynamic data) {
    print("\n\n\n\n\n\n\n\n\n" + data + "\n\n\n\n\n\n\n\n");
    setState(() {
      _roomId = data;
    });
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  _unSubscribes() {
    if (socketIO != null) {
      socketIO.unSubscribe("chat_direct", _onReceiveChatMessage);
    }
  }

  _reconnectSocket() {
    if (socketIO == null) {
      _connectSocket01();
    } else {
      socketIO.connect();
    }
  }

  _disconnectSocket() {
    if (socketIO != null) {
      socketIO.disconnect();
    }
  }

  _destroySocket() {
    if (socketIO != null) {
      SocketIOManager().destroySocket(socketIO);
    }
  }

  void _createRequest() async {
    if (socketIO != null) {
      socketIO.sendMessage("create", jsonEncode({'username' : 'Hello'}), _onReceiveChatMessage);
    }
  }

  void _joinRequest(String room) async {
    if (socketIO != null) {
      socketIO.sendMessage("join", jsonEncode({'username' : 'Hello2', 'room' : room}), _onReceiveChatMessage);
    }
  }

  void socketInfo(dynamic message) {
    print("Socket Info: " + message);
  }

  void _onReceiveChatMessage(dynamic message) {
    print("Message from UFO: " + message);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(
              child:
                  const Text('CONNECT  SOCKET 01', style: TextStyle(color: Colors.white)),
              color: Theme.of(context).accentColor,
              elevation: 0.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                _connectSocket01();
              },
            ),
            new RaisedButton(
              child: const Text('Create', style: TextStyle(color: Colors.white)),
              color: Theme.of(context).accentColor,
              elevation: 0.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                _createRequest();
              },
            ),
            new RaisedButton(
              child: const Text('Join',
                  style: TextStyle(color: Colors.white)),
              color: Theme.of(context).accentColor,
              elevation: 0.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                _joinRequest('ABCDE');
              },
            ),
            new Text(_roomId),
          ],
        ),
      ),
    );
  }
}