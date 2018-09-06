class BookModel {
  String title, thumbnail, publisher, publishedAt, id;
  List<String> authors;
  num pages, rating;
  bool isFavourite = false;
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
      this.publishedAt,
      this.isFavourite});

  /// Reads book info from [book] JSON.
  BookModel.fromJson(dynamic book) {
    var volumeInfo = book['volumeInfo'];

    try {
      this.raw = book;

      // Title
      this.title = volumeInfo['title'];

      // Id
      this.id = book['id'];

      // Authors
      this.authors =
          List.castFrom<dynamic, String>(volumeInfo['authors']) ?? [];

      // Publisher
      this.publisher = volumeInfo['publisher'] ?? '';

      // Page Count
      this.pages = volumeInfo['pageCount'];

      // Ratings
      this.rating = volumeInfo['averageRating'];

      // Thumbnail
      try {
        this.thumbnail = (volumeInfo['imageLinks']['smallThumbnail']);
      } catch (e) {
        // Setting default image on error.
        this.thumbnail = 'https://placehold.it/100x100?text=No+Image';

        print('While setting thumbnail : ' + e.toString());
      }

      // Published Date
      if (volumeInfo['publishedDate'] is String) {
        var parts = volumeInfo['publishedDate'].split('-');
        this.publishedAt = parts[0];
      }
    } catch (e) {
      print(e);
    }
  }
}
