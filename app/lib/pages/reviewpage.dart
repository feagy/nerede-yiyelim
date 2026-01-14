import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
          SnackBar(
            content: Text("Yorumlar yüklenemedi: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
        SnackBar(
          content: const Text("Yorum silindi ✅"),
          backgroundColor: const Color.fromARGB(255, 221, 133, 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silinemedi: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
        SnackBar(
          content: const Text("Yorum güncellendi ✅"),
          backgroundColor: const Color.fromARGB(255, 221, 133, 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Güncellenemedi: $e"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted){
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(Review review) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white, // 🤍
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: primaryOrange, // 🟠
            width: 2,
          ),
        ),
        title: Column(
          children: const [
            Icon(
              CupertinoIcons.trash,
              color: Colors.redAccent,
              size: 38,
            ),
            SizedBox(height: 8),
            Text(
              'Emin misin?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Bu yorumu silmek istediğine emin misin?\nBu işlem geri alınamaz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryOrange,
                    side: const BorderSide(color: primaryOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'İptal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Sil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteReview(review);
    }
  }


  Future<void> _editReview(Review review) async {
    int selectedRating = review.rating;
    final commentController =
        TextEditingController(text: review.comment ?? '');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(
                color: primaryOrange,
                width: 2,
              ),
            ),
            title: const Center(
              child: Text(
                'Yorumu Güncelle',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Puanınız",
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: primaryOrange,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: RatingBar.builder(
                            initialRating: selectedRating.toDouble(),
                            minRating: 1,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 32,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                            itemBuilder: (_, __) => const Icon(
                              Icons.star_border_purple500_rounded,
                              color: Color.fromARGB(255, 221, 133, 2),
                            ),
                            onRatingUpdate: (rating) {
                              setDialogState(() {
                                selectedRating = rating.toInt();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Yorumunuz",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Yorumunuzu buraya yazın...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: primaryOrange),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: primaryOrange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: primaryOrange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryOrange,
                        side: const BorderSide(color: primaryOrange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      final newComment = commentController.text.trim();
      if (newComment.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Yorum boş olamaz."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
      await _updateReview(review, selectedRating, newComment);
    }

    commentController.dispose();
  }


  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final bottomTab = Provider.of<BottomTabState>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Yorumlarım',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReviews,
              color: const Color.fromARGB(255, 221, 133, 2),
              child: _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble_text,
                            size: MediaQuery.of(context).size.height * 0.12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz yorum yok',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 221, 133, 2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 221, 133, 2)
                                    .withOpacity(0.15),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                if (_db == null) return;
                                final place = await _db!.placeDao
                                    .getPlaceById(review.placeId);
                                if (!mounted) return;
                                if (place == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Mekan bilgisi bulunamadı"),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (mounted) {
                                  bottomTab.setTab(3);
                                  bottomTab.navigatorKey.currentState!
                                      .pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => DetailedRestaurantPage(
                                        place: place,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Başlık ve Butonlar
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.placeName ?? 'Mekan',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                review.placeAddress ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
                                                    ?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF7F9FB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  CupertinoIcons.pencil,
                                                  color: Color(0xFF4285F4),
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _editReview(review),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF7F9FB),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  CupertinoIcons.trash,
                                                  color: Colors.redAccent,
                                                  size: 20,
                                                ),
                                                onPressed: () =>
                                                    _confirmDelete(review),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Yıldızlar
                                    Row(
                                      children: [
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review.rating
                                                  ? Icons
                                                      .star_border_purple500_rounded
                                                  : Icons.star_border,
                                              color: const Color.fromARGB(
                                                  255, 221, 133, 2),
                                              size: 20,
                                            );
                                          }),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${review.rating} / 5.0",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Yorum
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F9FB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review.comment ?? "Yorum bulunmuyor",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black87,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Yayınlanma: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(review.createdAt))}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                          ),
                                          if (review.updatedAt !=
                                              review.createdAt)
                                            Text(
                                              "Düzenleme: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(review.updatedAt))}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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