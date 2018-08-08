import 'dart:async';

import 'package:books2go/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/rxdart.dart';

class SearchBooksWidget extends StatefulWidget {
  @override
  State createState() => new _SearchBooksWidgetState();
}

class _SearchBooksWidgetState extends State<SearchBooksWidget> {
  List<Book> _items = new List();
  String uId;

  final subject = new PublishSubject<String>();

//  Future<String> getCurrentUserRef() async {
//    FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    return user.uid.toString();
//  }
  bool _isLoading = false;

  void _textChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      _clearList();
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _clearList();
    http
        .get("https://www.googleapis.com/books/v1/volumes?q=$text")
        .then((response) => response.body)
        .then(JSON.decode)
        .then((map) => map["items"])
        .then((list) {
          list.forEach(_addItem);
        })
        .catchError(_onError)
        .then((e) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  void _onError(dynamic d) {
    setState(() {
      _isLoading = false;
    });
  }

  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  void _addItem(item) {
    setState(() {
      _items.add(Book.fromJson(item));
    });
  }

  @override
  void initState() {
    super.initState();
    subject.stream
        .debounce(new Duration(milliseconds: 600))
        .listen(_textChanged);

    FirebaseAuth.instance.currentUser().then((user) {
      uId= user.uid;
    });
  }

  Widget _createSearchBar(BuildContext context) {
    return new Card(
        child: Row(
      children: <Widget>[
        new IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        new Expanded(
            child: TextField(
          autofocus: true,
          decoration: new InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16.0),
            hintText: 'Sherlock Holmes, Dan Brown, Life of Pi...',
          ),
          onChanged: (string) => (subject.add(string)),
        ))
      ],
    ));
  }

  Widget _createBookItem(BuildContext context, Book book) {
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

  Widget _createBookItemDescriptionSection(BuildContext context, Book book) {
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
          alignment: Alignment.centerRight,
          icon: new Icon(Icons.favorite_border),
          tooltip: 'favourate the books',
          onPressed: () { setState(() { _favourate(book);icon: new Icon(Icons.favorite_border);}); },//todo change icon here onclick event
        ),
//        Spacer(),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(600.0),
        child: const Text(''),
      ),
      body: new Container(
        padding:
            new EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 8.0),
        child: new Column(
          children: <Widget>[
            _createSearchBar(context),
            new Expanded(
              child: Card(
                child: _isLoading
                    ? Container(
                        child: Center(child: CircularProgressIndicator()),
                        padding: EdgeInsets.all(16.0),
                      )
                    : new ListView.builder(
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


  void _favourate(Book book) {
    final _favourateBook = FirebaseDatabase.instance.reference().child('favourates').child(uId);
    _favourateBook.push().set(book.toJson());
  }
}

class Book {
  String title, thumbnail, publisher, publishedAt;
  List<String> authors;
  num pages, rating;

  Book(
      {this.title,
      this.thumbnail,
      this.pages,
      this.rating,
      this.publisher,
      this.authors,
      this.publishedAt});

  Book.fromJson(dynamic book) {
    var volumeInfo = book['volumeInfo'];

    try {
      this.title = volumeInfo['title'];
      this.authors =
          List.castFrom<dynamic, String>(volumeInfo['authors']) ?? [];
      this.publisher = volumeInfo['publisher'] ?? '';
      this.pages = volumeInfo['pageCount'];
      this.rating = volumeInfo['averageRating'];

      try {
        this.thumbnail = (volumeInfo['imageLinks']['smallThumbnail']);  
      } catch (e) {
          this.thumbnail = 'https://placehold.it/100x100?text=No+Image';
          print('While setting thumbnail : ' + e.toString());
      }
    
      if (volumeInfo['publishedDate'] is String) {
        var parts = volumeInfo['publishedDate'].split('-');
        this.publishedAt = parts[0];
      }
    } catch (e) {
      print(e);
    }
  }
  toJson() {
    return {
      "title": title,
      "thumbnail":thumbnail,
      "pages": pages,
      "rating":rating,
      "publisher":publisher,
      "authors":authors,
      "publishedAt":publishedAt
    };
  }
}


