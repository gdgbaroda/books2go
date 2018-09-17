import 'package:flutter/material.dart';
import 'nav_drawer.dart';
import 'favourite_books.dart';

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books2Go'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () => _searchBook())
        ],
      ),
      body: FavBooksWidget(),
      drawer: NavDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera),
        onPressed: () => _scanBook(),
        label: Text('SCAN BOOK', style: TextStyle(letterSpacing: 0.0,),),
      ),
    );
  }

  void _scanBook() {
    Navigator.of(context).pushNamed('/camera');
  }

  void _searchBook() {
    Navigator.of(context).pushNamed('/search');
  }
}
