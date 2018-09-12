import 'dart:convert';
import 'package:books2go/BookModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class SearchBooksWidget extends StatefulWidget {
  final String initialSearch;

  SearchBooksWidget({Key key, this.initialSearch}) : super(key: key);

  @override
  State createState() => new _SearchBooksWidgetState();
}

class _SearchBooksWidgetState extends State<SearchBooksWidget> {
  List<BookModel> _items = new List();
  List<String> _favouriteBookIds = new List();
  String uId;

  final subject = new PublishSubject<String>();

  bool _isLoading = false;
  TextEditingController textEditingController = TextEditingController(text: '');

  void _textChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _isLoading = false;
      });

      // Removing list data.
      _clearList();

      return;
    }

    setState(() {
      _isLoading = true;
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
          icon: book.isFavourite
              ? new Icon(Icons.favorite, color: Color.fromARGB(255, 254, 0, 0))
              : new Icon(Icons.favorite_border),
          tooltip: 'Add to favourites',
          onPressed: () {
            if (this.mounted) {
              setState(() {
                // Changing state of isFavourite
                book.isFavourite = !book.isFavourite;

                _favourite(context, book, book.isFavourite);
              });
            }
          },
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

  /// Adds/removes book from user's favourite list.
  /// [book] contains book data.
  /// [addToFavourites] indicates whether to add or remove book from favourite list.
  void _favourite(BuildContext context, BookModel book, bool addToFavourites) {
    final _favouriteBook = FirebaseDatabase.instance
        .reference()
        .child(uId)
        .child('favourites')
        .child(book.id);

    // Adding book in favourite list.
    if (addToFavourites) {
      _favouriteBook.set(book.raw);

      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Added to favourite books.')));
    } // Removing book from favourite list.
    else {
      _favouriteBook.remove();

      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Removed from favourite books.')));
    }
  }
}

class Book {
  String title, thumbnail, publisher, publishedAt;
  List<String> authors;
  num pages, rating;
  bool isFavourite = false;

  Book(
      {this.title,
      this.thumbnail,
      this.pages,
      this.rating,
      this.publisher,
      this.authors,
      this.publishedAt,
      this.isFavourite});

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
        // Setting default image on error.
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
}
