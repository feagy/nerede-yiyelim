import 'dart:convert';
import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/database/entity/place.dart';
import 'package:app/services/placephotoservice.dart';
import 'package:get_it/get_it.dart';
import 'package:app/database/entity/review.dart';
import 'package:app/services/aisummaryservice.dart';
import 'package:app/services/reviewsservice.dart';
import 'package:app/database/services/localdbservice.dart';
import 'package:app/database/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/services/favoritesservice.dart';
import 'package:app/database/entity/favorite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*

  GETTERING DESIGN MUST BE CHANGED BEFORE DEPLOYMENT.

*/

class DetailedRestaurantPage extends StatefulWidget {
  final Place? place;
  const DetailedRestaurantPage({super.key, required this.place});

  @override
  State<DetailedRestaurantPage> createState() => _DetailedRestaurantPage();
}

class _DetailedRestaurantPage extends State<DetailedRestaurantPage> {
  late Place? place;
  final List<dynamic> _reviews = [];    
  String? _cursor;                     
  bool _hasMore = true;               
  bool _loadingMore = false;             
  bool _firstLoading = false;            
  static const int _limit = 10;
  Review?_myReview;
  bool isFavorite=false;
  late AppDataBase _db;
  String userName = "";
  // İnceleme için gerekli veriler
  final _commentCtrlSubmit = TextEditingController();
  final _commentCtrlUpdate = TextEditingController();
  int _selectedRating = 0; // 1..5
  bool _isSending = false;

  // Favori için gerekli veriler
  bool _isFavorite = false;
  bool _isFavoriteBusy = true;

  @override
  void initState() {
    super.initState();
    place = widget.place;
    _init(); 
  }

  @override
    void dispose() {
      _commentCtrlSubmit.dispose();
      _commentCtrlUpdate.dispose();
      super.dispose();
    }

    Future<void> _init() async {
    await loadDatabase();
    await getMyReview(); 
    await getFavoriteInfo();
    /* await _loadUserData(); */
    if (!mounted) return;

    if (place?.id != null) {
      await _loadFirstPage();
    }        
  }
    Future<void> _submitReview() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || place?.id == null || _isSending) return;

      final rating = _selectedRating;
      final comment = _commentCtrlSubmit.text.trim();

      if (rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen puan verin.")),
        );
        return;
      }
      if (comment.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yorum boş olamaz.")),
        );
        return;
      }

    setState(() {
      _isSending = true;
    });

    final newReview = Review(
      id: '${place!.id}_$userId',
      placeId: place!.id,
      placeName: place!.placeName,
      placeAddress: place!.address,
      userId: userId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await _db.reviewsDao.upsertReview(newReview);
      await _db.placeDao.upsertPlace(place!);
      await GetIt.I<ReviewsService>().addReview(newReview);

      if (!mounted) return;
      setState(() {
        _myReview = newReview;
        _commentCtrlSubmit.clear();
        _selectedRating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yorum gönderildi ✅")),
      );
    }catch(e){
      debugPrint("submit review error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gönderilemedi: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
    Future<void> _updateReview(int rating, String comment) async {
      if (_isSending) return;

      final userId = FirebaseAuth.instance.currentUser?.uid;
      final placeId = place?.id;
      if (userId == null || placeId == null || _myReview == null) return;

      setState(() {
        _isSending = true;
      });

      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = _myReview!.copyWith(
        rating: rating,
        comment: comment,
        updatedAt: now,
      );

      try {
        await _db.reviewsDao.upsertReview(updated);
        await GetIt.I<ReviewsService>().updateReview(
          placeId: placeId,
          userId: userId,
          rating: rating,
          comment: comment,
        );

        if (!mounted) return;
        setState(() {
          _myReview = updated;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yorum güncellendi ✅")),
        );
      } catch (e) {
        debugPrint("update review error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Güncellenemedi: $e")),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
    Future<void> _deleteReview() async {
        if (_isSending) return;

        final userId = FirebaseAuth.instance.currentUser?.uid;
        final placeId = place?.id;
        if (userId == null || placeId == null || _myReview == null) return;

        setState(() {
          _isSending = true;
        });

        final reviewId = '${placeId}_$userId';

        try {
          await _db.reviewsDao.deleteReview(reviewId);
          await GetIt.I<ReviewsService>().deleteReview(
            reviewId: reviewId
          );

          if (!mounted) return;
          setState(() {
            _myReview = null;
            _commentCtrlSubmit.clear();
            _selectedRating = 0;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yorum silindi ✅")),
          );
        } catch (e) {
          debugPrint("delete review error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Silinemedi: $e")),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isSending = false;
            });
          }
        }
  }
    Future<void> _toggleFavorite() async {
      if (_isFavoriteBusy) return;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final placeId = place?.id;
      if (userId == null || placeId == null) return;

      setState(() {
        _isFavoriteBusy = true;
      });

      final newStatus = !_isFavorite;

      setState(() {
        _isFavorite = newStatus;
      });

      try {
        if (newStatus) {
          final photoUrl = GetIt.I<PlacePhotoService>().getPhotoUrl(
            place?.photoName ?? "",
            400,
          );
          await _db.favoritesDao.insertFavorite(
            Favorite(
              id: '${placeId}_$userId',
              placeId: placeId,
              userId: userId,
              placeName: place?.placeName ?? "",
              placeAddress: place?.address ?? "",
              rating: place?.googleRating,
              photoUrl: photoUrl,
            ),
          );
          await _db.placeDao.upsertPlace(place!);
          await GetIt.I<FavoritesService>().addFavorite(
            placeId: placeId,
            userId: userId,
            placeName: place?.placeName ?? "",
            placeAddress: place?.address ?? "",
            rating: place?.googleRating ?? 0,
            photoUrl: photoUrl,
          );
        } else {
          final favoriteId = '${placeId}_$userId';
          await _db.favoritesDao.deleteFavorite(favoriteId);
          await GetIt.I<FavoritesService>().deleteFavorite(favoriteId);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isFavorite = !newStatus;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Favori güncellenemedi")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isFavoriteBusy = false;
          });
        }
      }
  }
    Future<void> getMyReview() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || place?.id == null) return;

      final r = await _db.reviewsDao.getUserReviewForPlace(
        place!.id,
        userId,
      );

      if (!mounted) return;
      setState(() => _myReview = r);
  }
    Future<void> getFavoriteInfo() async {
      if (mounted) {
        setState(() {
          _isFavoriteBusy = true;
        });
      }
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final placeId = place?.id;
      if (userId == null || placeId == null) {
        if (mounted) {
          setState(() {
            _isFavorite = false;
            _isFavoriteBusy = false;
          });
        } 
        return;
      }

      try{
        final isFavorite = await _db.favoritesDao.isFavorite(placeId!, userId) == 1;

        if (!mounted) return;
        setState(() {
          _isFavorite = isFavorite;
        });
      } catch(e){
        if (mounted){
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Favori bilgisi alınamadı")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isFavoriteBusy = false;
          });
        }
      }
  }
    Future<void> loadDatabase() async {
      _db = await LocalServices.getDatabase();
    }

    Future<void> _loadFirstPage() async {
    if (place?.id == null) return;

    try {
      if (!mounted) return;
      setState(() {
        _firstLoading = true;
        _reviews.clear();
        _cursor = null;
        _hasMore = true;
      });

      final resp = await GetIt.I<ReviewsService>().readReviews(
        placeId: place!.id!,
        limit: _limit,
        cursor: null,
      );

        resp.items.removeWhere((r) => r.userId == FirebaseAuth.instance.currentUser?.uid);
      
      if (!mounted) return;
      setState(() {
        _reviews.addAll(resp.items);
        _cursor = resp.nextCursor;
        _hasMore = resp.hasMore;
      });
    } catch (e) {
      debugPrint("First page error: $e");
    } finally {
      if (mounted) setState(() => _firstLoading = false);
    }
  }

 /*  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        userName = doc['nickname'] ?? "";
      }
    }
  } */

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    if (place?.id == null) return;

    try {
      setState(() => _loadingMore = true);

      final resp = await GetIt.I<ReviewsService>().readReviews(
        placeId: place!.id!,
        limit: _limit,
        cursor: _cursor, // <-- devam cursor’u
      );

        resp.items.removeWhere((r) => r.userId == FirebaseAuth.instance.currentUser?.uid);
      
      if (!mounted) return;

      setState(() {
        _reviews.addAll(resp.items); // <-- listeye ekle
        _cursor = resp.nextCursor;
        _hasMore = resp.hasMore;
      });
    } catch (e) {
      debugPrint("Load more error: $e");
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }


  Future<void> _openGoogleMaps(String? placeMapUri) async {
    if (placeMapUri != null) {
      final Uri url = Uri.parse(placeMapUri);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $placeMapUri');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return place != null ? Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _DetailedRestaurantHeader(
              restaurantName: place?.placeName,
              restaurantPhotoUri: GetIt.I<PlacePhotoService>().getPhotoUrl(
                place?.photoName ?? "",
                400,
              ),
              restaurantRating: place?.googleRating,
              restaurantUserRatingCount: place?.googleRatingCount,
              isOpen: jsonDecode(place?.openingHoursJson ?? "{}")["openNow"] as bool?,
              isFavorite: _isFavorite,
              onFavoriteToggle: _toggleFavorite,
              isFavoriteBusy: _isFavoriteBusy,
            ),
            _DetailedRestaurantInformationSection(
              restaurantFormattedaddress: place?.address,
              restaurantGenerativeSummary: "Butonla istenecek",
              restaurantInternationalPhoneNumber: place?.phone,
              restaurantNextCloseTime:
                  jsonDecode(place?.openingHoursJson ?? "{}")["nextCloseTime"] as String?,
            ),
            if (place?.googleMapsUri != null)
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(place?.googleMapsUri),
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text("Open in Google Maps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (_myReview != null)
             
              _DetailedRestaurantUserReviewSection(
                commentCtrl: _commentCtrlUpdate,
                userReview: _myReview, 
                onEdit: _updateReview,
                onDelete: _deleteReview,
                isSending: _isSending,
              )
            else
              _DetailedRestaurantWriteReviewSection(
                _commentCtrlSubmit,
                _selectedRating,
                _isSending,
                (rating) {
                  setState(() {
                    _selectedRating = rating.toInt();
                  });
                },
                _submitReview,
              ),

            _DetailedRestaurantCommentsSection(
              restaurantReviews: _reviews,  
            ),
            if (_firstLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (_hasMore)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: _loadingMore ? null : _loadMore,
                  child: _loadingMore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Daha fazla göster"),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text("Tüm yorumlar gösterildi."),
              ),
          ],
        ),
      ),
    ) : const Scaffold(
      body: Center(
        child: Center(
          child: Text("Haritadan bir mekan seçiniz."),
        ),
      ),
    );
  }
}

class _DetailedRestaurantHeader extends StatelessWidget {
  // They will change as final
  // and this application right now will terminate itself cause lack of API
  final String? restaurantPhotoUri;
  final String? restaurantName;
  final double? restaurantRating;
  final int? restaurantUserRatingCount;
  final bool? isOpen;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final bool isFavoriteBusy;

  const _DetailedRestaurantHeader({
    this.restaurantPhotoUri,
    this.restaurantName,
    this.restaurantRating,
    this.restaurantUserRatingCount,
    this.isOpen,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.isFavoriteBusy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        image: restaurantPhotoUri != null
            ? DecorationImage(
                image: NetworkImage(restaurantPhotoUri!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    restaurantName ?? "NO NAME",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: isOpen == true
                        ? const Color.fromARGB(255, 220, 255, 220)
                        : const Color.fromARGB(255, 255, 220, 220),
                  ),
                  child: Text(
                    isOpen == true ? "Open" : "Closed",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOpen == true
                          ? const Color.fromARGB(255, 0, 150, 0)
                          : const Color.fromARGB(255, 200, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBarIndicator(
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_border_purple500_rounded,
                    color: Color.fromARGB(255, 221, 133, 2),
                  ),
                  rating: restaurantRating ?? 0.0,
                  itemCount: 5,
                  itemSize: 25,
                  direction: Axis.horizontal,
                ),
                const SizedBox(width: 20),
                Text(
                  "(${restaurantUserRatingCount ?? 0} Yorum)",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 224, 224, 224),
                  ),
                ),
                const Spacer(),
                  AnimatedScale(
                  scale: isFavorite ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: 
                        isFavoriteBusy ? null : onFavoriteToggle,
                    ),
                  ),
                                  ), 
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedRestaurantInformationSection extends StatelessWidget {
  final String? restaurantFormattedaddress;
  final String? restaurantGenerativeSummary;
  final String? restaurantInternationalPhoneNumber;
  final String? restaurantNextCloseTime;

  const _DetailedRestaurantInformationSection({
    this.restaurantFormattedaddress,
    this.restaurantGenerativeSummary,
    this.restaurantInternationalPhoneNumber,
    this.restaurantNextCloseTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // I WILL DO IT WITH FLUTTER MAP. LEMME DO IT. - IHSAN
          // IF ANYONE WANT TO DO WATCH THIS https://www.youtube.com/watch?v=9L9Arynobzo&list=PLOEXB48nQMqMqhfwVsechVSYJBNrhZiNo
          Text(
            "AI-Generated Summary",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            restaurantGenerativeSummary ??
                "There is not a generative summary for this restaurant",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 32, 32, 32),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: CupertinoIcons.location,
            title: "Adres",
            content: restaurantFormattedaddress ?? "Address not available",
            context: context,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: CupertinoIcons.clock,
            title: "Çalışma Saati",
            content: restaurantNextCloseTime ?? "Unknown",
            context: context,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: CupertinoIcons.phone,
            title: "Telefon Numarası",
            content:
                restaurantInternationalPhoneNumber ?? "Phone not available",
            context: context,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 0, 0, 0), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 80, 80, 80),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailedRestaurantCommentsSection extends StatelessWidget {
  final List<dynamic>? restaurantReviews;
  
  const _DetailedRestaurantCommentsSection({this.restaurantReviews});

  @override
  Widget build(BuildContext context) {
    final reviews = restaurantReviews ?? [];

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kullanıcı Yorumları",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Text(
              "Henüz bir değerlendirme bulunmamaktadır.",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.grey[700],
              ),
            )
          else
            ...reviews.map((r) => _buildReviewCard(r, context)),
        ],
      ),
    );
  }

  Future<String> getUserName(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (doc.exists) {
      return doc['nickname'] ?? "Anonim";
    }
    return "Anonim";
  }

  Widget _buildReviewCard(Review review, BuildContext context) {
    // güvenli veri alma
    
    final double rating = review.rating.toDouble();
    final String text = review.comment ?? "";
    final String date = _formatDate(DateTime.fromMillisecondsSinceEpoch(review.updatedAt));

    return FutureBuilder(
      future: getUserName(review.userId),
      builder: (context, snapshot) {
        final author = snapshot.connectionState == ConnectionState.done && snapshot.hasData
            ? snapshot.data as String
            : "Yükleniyor...";
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FB),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kullanıcı ve tarih
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    author,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    date,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
        
              // Yıldızlar
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating
                        ? Icons.star_border_purple500_rounded
                        : Icons.star_border,
                    color: const Color.fromARGB(255, 221, 133, 2),
                    size: 20,
                  );
                }),
              ),
        
              const SizedBox(height: 8),
        
              // Yorum
              Text(
                text,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

//inceleme yazma windet eklenecek

class _DetailedRestaurantWriteReviewSection extends StatelessWidget {
  final TextEditingController commentCtrl;
  final int selectedRating;
  final bool isSending;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onSubmit;

  const _DetailedRestaurantWriteReviewSection(
    this.commentCtrl,
    this.selectedRating,
    this.isSending,
    this.onRatingChanged,
    this.onSubmit,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yorum Yaz",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Puanınız",
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RatingBar.builder(
            initialRating: 0,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 35,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star_border_purple500_rounded,
              color: Color.fromARGB(255, 221, 133, 2),
            ),
            onRatingUpdate: onRatingChanged
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Yorumunuzu buraya yazın...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed:  
              isSending ? null : onSubmit,
              child: isSending ? SizedBox(
                width: 18,
                height: 18,
                child: const CircularProgressIndicator(strokeWidth: 2.0)) : const Text("Gönder"),
          ),
        ],
      ),
    );
  }
}

class _DetailedRestaurantUserReviewSection extends StatelessWidget {
  final TextEditingController commentCtrl;
  final Review? userReview;
  final void Function(int rating, String comment)? onEdit;
  final VoidCallback? onDelete;
  final bool isSending;

  const _DetailedRestaurantUserReviewSection({
    required this.commentCtrl,
    this.userReview,
    this.onEdit,
    this.onDelete,
    required this.isSending
  });

  void _showEditDialog(BuildContext context, Review review) {
    commentCtrl.text = review.comment ?? "";

    int tempRating = review.rating.toInt();

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Yorumu Düzenle",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    initialRating: tempRating.toDouble(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 28,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_border_purple500_rounded,
                      color: Color.fromARGB(255, 221, 133, 2),
                    ),
                    onRatingUpdate: (rating) {
                      setDialogState(() {
                        tempRating = rating.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Yorumunuz"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Yorumunuzu buraya yazın...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  "İptal",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: isSending ? null : () {
                  final newComment = commentCtrl.text.trim();
                  if(tempRating == 0 || newComment.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen geçerli bir puan ve yorum giriniz.")),
                    );
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                  onEdit?.call(tempRating, newComment);
                },
                style: TextButton.styleFrom(foregroundColor: const Color.fromARGB(255, 221, 133, 2)),
                child: const Text(
                  "Güncelle",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Yorumu Sil",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bu yorumu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                "İptal",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: isSending ? null : () {
                Navigator.of(dialogContext).pop();
                onDelete?.call();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text(
                "Sil",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Eğer kullanıcının yorumu yoksa widget'ı gösterme
    if (userReview == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(214, 233, 232, 232),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Yorumunuz",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showEditDialog(context, userReview!);
                    },
                    icon: const Icon(
                      CupertinoIcons.pencil,
                      color: Color(0xFF4285F4),
                    ),
                    tooltip: "Düzenle",
                  ),
                  IconButton(
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                    icon: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.redAccent,
                    ),
                    tooltip: "Sil",
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
                    index < userReview!.rating
                        ? Icons.star_border_purple500_rounded
                        : Icons.star_border,
                    color: const Color.fromARGB(255, 221, 133, 2),
                    size: 24,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                "${userReview!.rating.toStringAsFixed(1)} / 5.0",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Yorum metni
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userReview!.comment ?? "Yorum bulunmuyor",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Yayınlanma: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(userReview!.createdAt))}",
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: Colors.grey[600]),
                ),
                if (userReview!.updatedAt != userReview!.createdAt)
                  Text(
                    "Düzenleme: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(userReview!.updatedAt))}",
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
}

String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

