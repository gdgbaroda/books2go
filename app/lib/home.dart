import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'nav_drawer.dart';
import 'root_context.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {

  @override
  Widget build(BuildContext context) {
    RootContext rootContext = context.inheritFromWidgetOfExactType(RootContext);

    return Scaffold(
      appBar: AppBar(
        title: Text('Books2Go'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: this.createWelcomeScreen(rootContext.user),
        ),
      ),
      drawer: NavDrawer(),
    );
  }

  List<Widget> createWelcomeScreen(FirebaseUser user) {
    return <Widget>[
      Icon(
        Icons.tag_faces,
        size: 100.0,
        color: Colors.amber,
      ),
      Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: Text("Welcome ${user.displayName}!",
            style: TextStyle(fontSize: 15.0, color: Colors.black87)),
      ),
    ];
  }
}
