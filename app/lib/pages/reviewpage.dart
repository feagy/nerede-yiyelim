import 'package:flutter/material.dart';
import 'package:app/database/entity/review.dart';
import 'package:app/pages/detailedrestaurantpage.dart';
import 'package:app/database/database.dart';
import 'package:app/database/services/localdbservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:app/services/reviewsservice.dart';
import 'package:provider/provider.dart';
import 'package:app/global/universaltheme.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Review> _reviews = [];

  AppDataBase? _db;
  String? _userId;
  bool _isLoading = false;
  bool _isSending = false;
  
  @override
  void initState() {
    super.initState();
    _init();
    }


  Future<void> _init() async {
    final db = await LocalServices.getDatabase();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (!mounted) return;

    setState(() {
      _db = db;
      _userId = userId ?? "";
    });

    await _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (_isLoading) return;
    if (_db == null || _userId == null || _userId!.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try{
      final reviews = _userId!.isNotEmpty
          ? await _db!.reviewsDao.getReviewsByUser(_userId!)
          : <Review>[];

      if (!mounted) return;
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Yorumlar yüklenemedi: $e")),
        );
      }
    } finally {
      if (mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReview(Review review) async {
    if (_isSending) return;
    if (_db == null || _userId == null || _userId!.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isSending = true;
    });

    try {
      await _db!.reviewsDao.deleteReview(review.id);
      await GetIt.I<ReviewsService>().deleteReview(
        reviewId: review.id,
      );

      if (!mounted) return;
      setState(() {
        _reviews.removeWhere((r) => r.id == review.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum silindi ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silinemedi: $e")),
      );
    } finally {
      if (mounted){
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _updateReview(Review review, int newRating, String newComment) async {
    if (_isSending) return;
    if (_db == null || _userId == null || _userId!.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isSending = true;
    });
    
    final updatedReview = Review(
      id: review.id,
      userId: _userId!,
      placeId: review.placeId,
      placeName: review.placeName,
      placeAddress: review.placeAddress,
      rating: newRating,
      comment: newComment,
      createdAt: review.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    try{
      await _db!.reviewsDao.upsertReview(updatedReview);
      await GetIt.I<ReviewsService>().updateReview(
        placeId: review.placeId,
        userId: _userId!,
        rating: newRating,
        comment: newComment,
      );

      if (!mounted) return;
      setState(() {
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _reviews[index] = updatedReview;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum güncellendi ✅")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Güncellenemedi: $e")),
      );
    } finally {
      if (mounted){
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  

  // Delete confirmation
  
  Future<void> _confirmDelete(Review review) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emin misin?'),
        content: const Text('Bu yorumu silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteReview(review);
    }
  }

  
  // Edit review dialog
  
  Future<void> _editReview(Review review) async {
    int selectedRating = review.rating;
    final commentController =
        TextEditingController(text: review.comment ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yorumu Güncelle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedRating,
                decoration: const InputDecoration(labelText: 'Puan'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} ⭐'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) selectedRating = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Yorum'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newComment = commentController.text.trim();
        if (newComment.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yorum boş olamaz.")),
          );
          return;
        }
      await _updateReview(review, selectedRating, newComment);
    }
    commentController.dispose();
  }

  
  // UI
  
  @override
  Widget build(BuildContext context) {
    final bottomTab = Provider.of<BottomTabState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlarım'),
        
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReviews,
              child:  ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
            
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(review.rating.toString()),
                    ),
                    title: Text(
                      review.placeName ?? 'Mekan',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(review.comment ?? ''),
                    onTap: () async {
                      if (_db == null) return;
                      final place = await _db!.placeDao.getPlaceById(review.placeId);
                        if (!mounted) return;
                        if (place == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Mekan bilgisi bulunamadı")),
                          );
                          return;
                        }
                        if (mounted) {
                          bottomTab.setTab(3);
                          bottomTab.navigatorKey.currentState!.pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => DetailedRestaurantPage(
                                place: place,
                              ),
                            ),
                          );
                        }
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editReview(review),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(review),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
                ),
          ),
        ],
      ),
    );

    
  }
}
