import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'BookModel.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final bool favorited;

  BookCard(this.book, this.favorited);

  @override
  State<StatefulWidget> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  String uId;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      uId = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _createBookItem(context, widget.book);
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
          splashColor: null,
          padding: EdgeInsets.all(0.0),
          alignment: Alignment.centerLeft,
          icon: book.isFavourite
              ? new Icon(Icons.bookmark, color: Color.fromARGB(255, 254, 0, 0))
              : new Icon(Icons.bookmark_border),
          tooltip: 'Add to favourites',
          onPressed: () {
            _favourite(context, book, !book.isFavourite);
          },
        ),
        book.rating != null
            ? Row(
                children: <Widget>[
                  Icon(
                    Icons.star,
                    size: 12.0,
                    color: Colors.amber,
                  ),
                  Text(
                    book.rating.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12.0,
                    ),
                  )
                ],
              )
            : Container()
      ],
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

    setState(() {
      // Adding book in favourite list.
      if (addToFavourites) {
        book.isFavourite = true;
        _favouriteBook.set(book.raw);
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Added to favourite books.')));
      } // Removing book from favourite list.
      else {
        book.isFavourite = false;
        _favouriteBook.remove();
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('Removed from favourite books.')));
      }
    });
  }
}
