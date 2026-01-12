import 'dart:convert';

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
  late ReviewsResponse reviews;

  @override
  void initState() {
    super.initState();
    place = widget.place;
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

            if (true)
              // Kullanıcının yorumu varsa true yapın
              _DetailedRestaurantUserReviewSection(
                userReview: Review(
                  id: "review1",
                  userId: "user123",
                  placeId: place?.id ?? "",
                  placeName: place?.placeName ?? "",
                  placeAddress: place?.address ?? "",
                  rating: 4,
                  comment: "Harika bir deneyimdi!",
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ),
                onEdit: () {},
                onDelete: () {},
              )
            else
              _DetailedRestaurantWriteReviewSection(),

            _DetailedRestaurantCommentsSection(
              restaurantReviews: [], // ReviewsService den gelecek
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

  const _DetailedRestaurantHeader({
    this.restaurantPhotoUri,
    this.restaurantName,
    this.restaurantRating,
    this.restaurantUserRatingCount,
    this.isOpen,
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

  Widget _buildReviewCard(dynamic review, BuildContext context) {
    // güvenli veri alma
    final String author = review["author"] ?? "Anonymous";
    final double rating = (review["rating"] ?? 0).toDouble();
    final String text = review["text"] ?? "";
    final String date = review["publishTime"];

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
}

//inceleme yazma windet eklenecek

class _DetailedRestaurantWriteReviewSection extends StatelessWidget {
  const _DetailedRestaurantWriteReviewSection();

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
            onRatingUpdate: (rating) {
              // Rating değeri burada kullanılabilir
              print("Seçilen puan: $rating");
            },
          ),
          const SizedBox(height: 16),
          TextField(
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
            onPressed: () {
              // Yorum gönderme işlemi burada yapılacak
            },
            child: const Text("Gönder"),
          ),
        ],
      ),
    );
  }
}

class _DetailedRestaurantUserReviewSection extends StatelessWidget {
  final Review? userReview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DetailedRestaurantUserReviewSection({
    this.userReview,
    this.onEdit,
    this.onDelete,
  });

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
                    onPressed: onEdit,
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

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (onDelete != null) {
                  onDelete!();
                }
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
}
