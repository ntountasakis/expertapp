import 'package:expertapp/src/firebase/database/database_paths.dart';
import 'package:expertapp/src/firebase/database/database_util.dart';

class Review {
  final String reviewerUid;
  final String review;
  final double rating;

  Review(this.reviewerUid, this.review, this.rating);

  Future<void> put(String revieweeUid) async {
    await DatabaseUtil.put(_path(revieweeUid, revieweeUid), _toRTDB());
  }

  static Stream<List<Review>> getStream(String revieeUid) {
    final Stream<List<Map<String, dynamic>>> reviewStream =
        DatabaseUtil.getEntryStream(_pathToAllReviews(revieeUid));
    return reviewStream.map((List<Map<String, dynamic>> event) {
      final reviews = <Review>[];

      event.forEach((reviewMaps) {
        reviewMaps.forEach((key, value) {
          final reviewMap =
              Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
          reviews.add(_fromRTDB(key, reviewMap));
        });
      });
      return reviews;
    });
  }

  static String _path(String revieeUid, String reviewerUid) {
    return DatabasePaths.EXPERT_REVIEWS + revieeUid + '/' + revieeUid;
  }

  static String _pathToAllReviews(String revieeUid) {
    return DatabasePaths.EXPERT_REVIEWS + revieeUid;
  }

  Map<String, dynamic> _toRTDB() {
    return {'review': review, 'rating': rating};
  }

  static Review _fromRTDB(String reviewerUid, Map<String, dynamic> data) {
    return Review(reviewerUid, data['review'], data['rating']);
  }
}
