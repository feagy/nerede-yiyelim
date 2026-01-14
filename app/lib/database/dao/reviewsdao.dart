import 'package:floor/floor.dart';
import 'package:app/database/entity/review.dart';

@dao
abstract class ReviewsDao {
  @Query('SELECT * FROM reviews WHERE placeId = :placeId ORDER BY updatedAt DESC LIMIT :limit OFFSET :offset')
  Future<List<Review>> getReviews(String placeId, int limit, int offset);

  @Query('SELECT EXISTS(SELECT 1 FROM reviews WHERE placeId = :placeId AND userId = :userId)')
  Future<int?> hasUserReviewed(String placeId, String userId);

  @Query('DELETE FROM reviews WHERE id = :reviewId')
  Future<void> deleteReview(String reviewId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertReview(Review review);

  @Query('SELECT * FROM reviews WHERE placeId = :placeId AND userId = :userId LIMIT 1')
  Future<Review?> getUserReviewForPlace(String placeId, String userId);

  @Query('SELECT * FROM reviews WHERE userId = :userId ORDER BY updatedAt DESC')
  Future<List<Review>> getReviewsByUser(String userId);
}