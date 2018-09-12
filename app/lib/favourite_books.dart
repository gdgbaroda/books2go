import 'package:books2go/BookModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavBooksWidget extends StatefulWidget {
  @override
  State createState() => new _FavBooksWidgetState();
}

class _FavBooksWidgetState extends State<FavBooksWidget> {
  List<BookModel> _items = new List();
  String uId;
  bool _isLoading = false;

  _FavBooksWidgetState() {
    FirebaseAuth.instance.currentUser().then((user) {
      uId = user.uid;

      // Adding listener for favourite books.
      final mainReference =
          FirebaseDatabase.instance.reference().child(uId).child('favourites');
      mainReference.onChildAdded.listen(_onEntryAdded);
    });
  }

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    Widget _createBookItemDescriptionSection(
        BuildContext context, BookModel book) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Text(
            book.authors.join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.0,
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(0.0),
            alignment: Alignment.centerLeft,
            icon:
                new Icon(Icons.favorite, color: Color.fromARGB(255, 254, 0, 0)),
            tooltip: 'favourite the books',
            onPressed: () {},
          ),
          book.rating != null
              ? Row(
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      size: 12.0,
                      color: Colors.black45,
                    ),
                    Text(
                      book.rating.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12.0,
                      ),
                    )
                  ],
                )
              : Container()
        ],
      );
    }

    Widget _createBookItem(BuildContext context, BookModel book) {
      return new Column(
        children: <Widget>[
          Padding(
              padding: new EdgeInsets.all(8.0),
              child: new Row(
                children: <Widget>[
                  new Image.network(book.thumbnail,
                      height: 120.0, width: 80.0, fit: BoxFit.fitHeight),
                  Expanded(
                      child: Container(
                    height: 120.0,
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: _createBookItemDescriptionSection(context, book),
                  )),
                ],
              )),
          new Divider()
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Books'),
      ),
      body: new Container(
        padding:
            new EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: Card(
                child: _isLoading
                    ? Container(
                        child: Center(child: CircularProgressIndicator()),
                        padding: EdgeInsets.all(16.0),
                      )
                    : new ListView.builder(
                        reverse: false,
                        physics: BouncingScrollPhysics(),
                        padding: new EdgeInsets.all(8.0),
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _createBookItem(context, _items[index]);
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _onEntryAdded(Event event) {
    if (this.mounted) {
      setState(() {
        dynamic raw = event.snapshot.value;
        _items.add(new BookModel.fromJson(raw));
      });
    }
  }
}
