import 'package:firebase_database/firebase_database.dart';

class BookModel {
  String title, thumbnail, publisher, publishedAt,id;
  List<String> authors;
  num pages, rating;
  dynamic raw;

  BookModel(
      {this.title,
        this.id,
        this.raw,
        this.thumbnail,
        this.pages,
        this.rating,
        this.publisher,
        this.authors,
        this.publishedAt});

  BookModel.fromJson(dynamic book) {
    var volumeInfo = book['volumeInfo'];

    try {
      this.raw = book;
      this.title = volumeInfo['title'];
      this.id = book['id'];
      this.authors = List.castFrom<dynamic, String>(volumeInfo['authors']) ?? [];
      this.publisher = volumeInfo['publisher'] ?? '';
      this.pages = volumeInfo['pageCount'];
      this.rating = volumeInfo['averageRating'];

      try {
        this.thumbnail = (volumeInfo['imageLinks']['smallThumbnail']);
      }

      catch (e) {
        this.thumbnail = 'https://placehold.it/100x100?text=No+Image';
        print('While setting thumbnail : ' + e.toString());
      }

      if (volumeInfo['publishedDate'] is String) {
        var parts = volumeInfo['publishedDate'].split('-');
        this.publishedAt = parts[0];
      }
    }
    catch (e) {
      print(e);
    }
  }
}