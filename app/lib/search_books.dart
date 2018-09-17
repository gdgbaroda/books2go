import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'book_card.dart';
import 'BookModel.dart';

class SearchBooksWidget extends StatefulWidget {
  final String initialSearch;

  SearchBooksWidget({Key key, this.initialSearch}) : super(key: key);

  @override
  State createState() => new _SearchBooksWidgetState();
}

class _SearchBooksWidgetState extends State<SearchBooksWidget> {
  List<BookModel> _items = new List();
  List<String> _favouriteBookIds = new List();
  String uId, search;

  final subject = new PublishSubject<String>();

  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController(text: '');

  void _textChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
        search = null;
      });

      // Removing list data.
      _clearList();

      return;
    }

    setState(() {
      _isLoading = true;
      search = text;
    });

    // Removing list data.
    _clearList();

    // Calling Google Books api.
    http
        .get("https://www.googleapis.com/books/v1/volumes?q=$text")
        .then((response) => response.body)
        .then(JsonDecoder().convert)
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

  /// Removes list data.
  void _clearList() {
    setState(() {
      _items.clear();
    });
  }

  void _addItem(item) {
    print(item);
    setState(() {
      var bookModel = BookModel.fromJson(item);

      // Checking whether searched book is already added in favourite books or not
      for (var bookId in _favouriteBookIds) {
        if (bookId == bookModel.id) {
          bookModel.isFavourite = true;

          break;
        }
      }

      _items.add(bookModel);
    });
  }

  @override
  void initState() {
    super.initState();
    subject.stream
        .debounce(new Duration(milliseconds: 600))
        .listen(_textChanged);

    FirebaseAuth.instance.currentUser().then((user) {
      uId = user.uid;

      // Getting list of favourite books of user
      FirebaseDatabase.instance
          .reference()
          .child(uId)
          .child('favourites')
          .onValue
          .listen((Event event) {
        // Removing old favourite book ids
        _favouriteBookIds.clear();

        // Adding favourite book ids to list (if any)
        if (event.snapshot.value != null) {
          Map map = event.snapshot.value;

          void iterateMapEntry(key, value) {
            map[key] = value;

            _favouriteBookIds.add(value['id'] as String);
          }

          map.forEach(iterateMapEntry);
        }
      }, onError: (Object o) {});
    });

    if (widget.initialSearch != null) {
      textEditingController.text = widget.initialSearch;
      subject.add(widget.initialSearch);
    }
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
          controller: textEditingController,
          decoration: new InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16.0),
            hintText: 'Search Books',
          ),
          onChanged: (string) => (subject.add(string)),
        ))
      ],
    ));
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
                child: _searchResults(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchResults() {
    if (_isLoading) {
      return Container(
        child: Center(child: CircularProgressIndicator()),
        padding: EdgeInsets.all(16.0),
      );
    } else {
      if (_items.length == 0) {
        return Container(
          child: Center(
            child: Text(search != null?'Oops! No Results':'Enter to search'),
          ),
        );
      } else {
        return ListView.builder(
          padding: new EdgeInsets.all(8.0),
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            return BookCard(_items[index], _items[index].isFavourite);
          },
        );
      }
    }
  }
}
