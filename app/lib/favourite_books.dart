import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_card.dart';
import 'BookModel.dart';

class FavBooksWidget extends StatefulWidget {
  @override
  State createState() => new _FavBooksWidgetState();
}

class _FavBooksWidgetState extends State<FavBooksWidget> {
  List<BookModel> _items = new List();
  String uId;
  FirebaseUser user;
  bool _isLoading = false;

  _FavBooksWidgetState() {
    FirebaseAuth.instance.currentUser().then((user) {
      this.user = user;
      uId = user.uid;

      // Adding listener for favourite books.
      final mainReference =
          FirebaseDatabase.instance.reference().child(uId).child('favourites');
      mainReference.onValue.listen(_onEntryAdded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.all(8.0),
      child: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
              padding: EdgeInsets.all(16.0),
            )
          : _items.length == 0
              ? createWelcomeScreen()
              : ListView.builder(
                  reverse: false,
                  physics: BouncingScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return BookCard(_items[index], true);
                  },
                ),
    );
  }

  Widget createWelcomeScreen() {
    String name = this.user?.displayName ?? '';

    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Icon(
            Icons.tag_faces,
            size: 100.0,
            color: Colors.black12,
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Text("Welcome ${name}!",
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold)),
          ),
        ]));
  }

  _onEntryAdded(Event event) {
    print('fav updated');
    if (this.mounted) {
      setState(() {
        _items.clear();
        dynamic value = event.snapshot.value;
        if (value != null) {
          for (dynamic raw in value.values) {
            BookModel book = BookModel.fromJson(raw);
            book.isFavourite = true;
            _items.add(book);
          }
        }
      });
    }
  }
}
