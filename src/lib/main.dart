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
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _roomId = 'None';
  
  var roomIdController = new TextEditingController();
  var usernameController = new TextEditingController();

  SocketIO socketIO;

  List<dynamic> _users = <dynamic>[];
  
  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  _connectSocket() {
    socketIO = SocketIOManager().createSocketIO("http://10.0.2.2:5000", "/user", query: "userId=21031", socketStatusCallback: _callMeFromPython);
    socketIO.init();
    socketIO.subscribe("call_me", _callMeFromPython);
    socketIO.connect();
  }

  _callMeFromPython(dynamic data) {
    List<dynamic> newUsers = jsonDecode(data);
    setState(() {
      _users = newUsers;
    });
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  _unSubscribes() {
    if (socketIO != null) {
      socketIO.unSubscribe("chat_direct", _onReceive);
    }
  }

  _reconnectSocket() {
    if (socketIO == null) {
      _connectSocket();
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
      socketIO.sendMessage("create", jsonEncode({'username' : usernameController.text}), _onReceive);
    }
  }

  void _joinRequest() async {
    if (socketIO != null) {
      socketIO.sendMessage("join", jsonEncode({'username' : usernameController.text, 'room' : roomIdController.text}), _onReceive);
    }
  }

  void socketInfo(dynamic message) {
    print("Socket Info: " + message);
  }

  void _onReceive(dynamic message) {
    setState(() {
      _roomId = message;
    });
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
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: new TextField(
                  controller: usernameController,
                  decoration: new InputDecoration(hintText: "Enter username")
              ),
            ),
            new Text("RoomID: " + _roomId),
            new RaisedButton(
              child: const Text('Create', style: TextStyle(color: Colors.white)),
              color: Theme.of(context).accentColor,
              elevation: 0.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                _createRequest();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: new TextField(
                  controller: roomIdController,
                  decoration: new InputDecoration(hintText: "Enter existing Room ID")
              ),
            ),
            new RaisedButton(
              child: const Text('Join',
              style: TextStyle(color: Colors.white)),
              color: Theme.of(context).accentColor,
              elevation: 0.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                _joinRequest();
              },
            ),
            new ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _users.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: Center(child: Text('${_users[index]}')),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ],
        ),
      ),
    );
  }
}