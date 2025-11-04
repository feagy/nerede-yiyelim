import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


/*

  GETTERING DESIGN MUST BE CHANGED BEFORE DEPLOYMENT.

*/

final restaurant = {
  "name": "Mikla Restaurant",
  "id": "mikla-istanbul",
  "displayName": {"text": "Mikla"},
  "types": [
    "restaurant",
    "fine_dining",
    "point_of_interest",
    "establishment"
  ],
  "primaryType": "restaurant",
  "primaryTypeDisplayName": {"text": "Fine Dining Restaurant"},
  "nationalPhoneNumber": "0212 293 56 56",
  "internationalPhoneNumber": "+90 212 293 56 56",
  "formattedAddress": "The Marmara Pera, Meşrutiyet Cd. No:15, 34430 Beyoğlu/İstanbul, Türkiye",
  "shortFormattedAddress": "Meşrutiyet Cd. No:15, Beyoğlu",
  "postalAddress": {
    "regionCode": "TR",
    "postalCode": "34430",
    "administrativeArea": "İstanbul",
    "locality": "Beyoğlu",
    "addressLines": [
      "Meşrutiyet Cd. No:15",
      "The Marmara Pera Hotel"
    ]
  },
  "location": {"latitude": 41.031203, "longitude": 28.9716919},
  "rating": 4.7,
  "userRatingCount": 980,
  "googleMapsUri": "https://maps.google.com/?cid=1234567890123456789",
  "websiteUri": "https://www.miklarestaurant.com",
  "reviews": [
    {
      "author": "Selin Arslan",
      "rating": 5,
      "text": "Manzara muhteşem, yemekler yaratıcı ve çok lezzetli!",
      "publishTime": "2025-10-12T20:15:00Z"
    },
    {
      "author": "Emre Demir",
      "rating": 4,
      "text": "Servis çok iyi ama fiyatlar biraz yüksek.",
      "publishTime": "2025-09-05T18:45:00Z"
    }
  ],
  "regularOpeningHours": {
    "periods": [
      {"open": {"day": 1, "hour": 18, "minute": 0}, "close": {"day": 2, "hour": 0, "minute": 0}},
      {"open": {"day": 2, "hour": 18, "minute": 0}, "close": {"day": 3, "hour": 0, "minute": 0}},
      {"open": {"day": 3, "hour": 18, "minute": 0}, "close": {"day": 4, "hour": 0, "minute": 0}},
      {"open": {"day": 4, "hour": 18, "minute": 0}, "close": {"day": 5, "hour": 0, "minute": 0}},
      {"open": {"day": 5, "hour": 18, "minute": 0}, "close": {"day": 6, "hour": 1, "minute": 0}},
      {"open": {"day": 6, "hour": 18, "minute": 0}, "close": {"day": 0, "hour": 1, "minute": 0}}
    ],
    "weekdayDescriptions": [
      "Pazartesi: 18:00 - 00:00",
      "Salı: 18:00 - 00:00",
      "Çarşamba: 18:00 - 00:00",
      "Perşembe: 18:00 - 00:00",
      "Cuma: 18:00 - 01:00",
      "Cumartesi: 18:00 - 01:00",
      "Pazar: Kapalı"
    ],
    "openNow": false,
    "nextOpenTime": "2025-11-03T18:00:00+03:00",
    "nextCloseTime": "2025-11-04T00:00:00+03:00"
  },
  "timeZone": {"id": "Europe/Istanbul"},
  "photos": [
    {
      "name": "photos/mikla1",
      "widthPx": 1280,
      "heightPx": 960,
      "authorAttributions": ["@MiklaRestaurant"],
      "photoUri": "https://www.miklarestaurant.com/images/gallery/mikla1.jpg"
    }
  ],
  "businessStatus": "OPERATIONAL",
  "priceLevel": "PRICE_LEVEL_EXPENSIVE",
  "editorialSummary": {
    "text": "Modern Türk mutfağını dünya standartlarında sunan, Boğaz manzaralı fine dining restoran."
  },
  "generativeSummary": {
    "overview": {
      "text": "Mikla Restaurant, İstanbul'un en seçkin fine dining mekanlarından biridir. Modern Türk mutfağını yaratıcı dokunuşlarla sunarken, Boğaz manzarasıyla misafirlerine unutulmaz bir deneyim yaşatır.",
      "languageCode": "tr"
    },
    "description": {
      "text": "The Marmara Pera Oteli'nin terasında yer alan Mikla, şef Mehmet Gürs'ün vizyonuyla geleneksel Anadolu tatlarını modern gastronomiyle birleştirir. Ziyaretçiler servis kalitesi, etkileyici şehir manzarası ve şarap menüsünü özellikle övmektedir. Hem yerli hem yabancı gurmeler tarafından İstanbul'un en iyi restoranlarından biri olarak gösterilmektedir.",
      "languageCode": "tr"
    }
  },
  "paymentOptions": {"acceptsCreditCards": true, "acceptsCashOnly": false},
  "parkingOptions": {"valetParking": true, "streetParking": false},
  "servesDinner": true,
  "servesWine": true,
  "servesDessert": true,
  "outdoorSeating": true,
  "goodForGroups": true,
  "reservable": true,
  "accessibilityOptions": {
    "wheelchairAccessibleEntrance": true,
    "wheelchairAccessibleRestroom": true
  },
  "pureServiceAreaBusiness": false
};


class DetailedRestaurantPage extends StatefulWidget {
  const DetailedRestaurantPage({super.key});

  @override
  State<DetailedRestaurantPage> createState () => _DetailedRestaurantPage();
}

class _DetailedRestaurantPage extends State<DetailedRestaurantPage> {
  String? get restaurantMapUri => restaurant["googleMapsUri"] as String?; 
  
  Future<void> _openGoogleMaps() async {
    if (restaurantMapUri != null) {
      final Uri url = Uri.parse(restaurantMapUri!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch $restaurantMapUri');
      }
    }
  }
  
  @override
  Widget build (BuildContext context) {
    // IT WILL COMPLETELY CHANGE
    print("=== RESTAURANT DATA DEBUG ===");
    print("Restaurant: $restaurant");
    print("regularOpeningHours: ${restaurant["regularOpeningHours"]}");
    print("generativeSummary: ${restaurant["generativeSummary"]}");

    final regularHours = restaurant["regularOpeningHours"] as Map?;
    final generativeSummary = restaurant["generativeSummary"] as Map?;
    final overview = generativeSummary?["overview"] as Map?;

    print("regularHours: $regularHours");
    print("generativeSummary: $generativeSummary");
    print("overview: $overview");
    print("overview text: ${overview?["text"]}");
    print("openNow: ${regularHours?["openNow"]}");
    print("nextCloseTime: ${regularHours?["nextCloseTime"]}");
    print("=== END DEBUG ===");
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            DetailedRestaurantHeader(
              restaurantName: restaurant["name"] as String?,
              restaurantPhotoUri: "https://lh3.googleusercontent.com/gps-cs-s/AG0ilSxF1kIayE8ncojdeqpOhlFkHB3Gf_JsOxBtWFnIMfAoVql5IQST8TIYYapEtCrkPBZjWV3Sz9nBICXKq3ZxvFfHCPEeXUFoEqtdsFB8nXFHVmsaXup_mU9nRpGJgIrmeOZwAByBLQ=s680-w680-h510-rw",
              restaurantRating: restaurant["rating"] as double?,
              restaurantUserRatingCount: restaurant["userRatingCount"] as int?,
              isOpen: regularHours?["openNow"] as bool?,
            ),
            DetailedRestaurantInformationSection(
              restaurantFormattedaddress: restaurant["formattedAddress"] as String?,
              restaurantGenerativeSummary: overview?["text"] as String?,
              restaurantInternationalPhoneNumber: restaurant["internationalPhoneNumber"] as String?,
              restaurantNextCloseTime: regularHours?["nextCloseTime"] as String?,
            ),
            if (restaurantMapUri != null)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _openGoogleMaps,
                icon: const Icon(Icons.map, size: 20),
                label: const Text("Open in Google Maps"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            DetailedRestaurantCommentsSection(
              restaurantReviews: restaurant["reviews"] as List<dynamic>?,
            )
          ],
        ),
      ),
    );
  }
}

class DetailedRestaurantHeader extends StatelessWidget {

  // They will change as final
  // and this application right now will terminate itself cause lack of API 
  final String? restaurantPhotoUri;
  final String? restaurantName;
  final double? restaurantRating;
  final int? restaurantUserRatingCount;
  final bool? isOpen;


  const DetailedRestaurantHeader({
    super.key,
    this.restaurantPhotoUri,
    this.restaurantName,
    this.restaurantRating,
    this.restaurantUserRatingCount,
    this.isOpen
  });

 @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        image: restaurantPhotoUri != null ? DecorationImage(
          image: NetworkImage(restaurantPhotoUri!),
          fit: BoxFit.cover,
        ) : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)]
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  restaurantName ?? "NO NAME",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: isOpen == true 
                     ? const Color.fromARGB(255, 220, 255, 220) 
                     : const Color.fromARGB(255, 255, 220, 220) 
                  ),
                  child: Text(
                    isOpen == true ? "Open" : "Closed",
                    style: GoogleFonts.lato(
                      color: isOpen == true
                       ? const Color.fromARGB(255, 0, 150, 0) 
                       : const Color.fromARGB(255, 200, 0, 0),
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBarIndicator(
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_border_purple500_rounded,
                    color: const Color.fromARGB(255, 221, 133, 2),
                  ),
                  rating: restaurantRating ?? 0.0,
                  itemCount: 5,
                  itemSize: 25,
                  direction: Axis.horizontal,
                ),
                const SizedBox(width: 20),
                Text(
                  "(${restaurantUserRatingCount ?? 0} Yorum)",
                  style: GoogleFonts.lato(
                    color: const Color.fromARGB(255, 224, 224, 224),
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DetailedRestaurantInformationSection extends StatelessWidget {
  final String? restaurantFormattedaddress;
  final String? restaurantGenerativeSummary;
  final String? restaurantInternationalPhoneNumber;
  final String? restaurantNextCloseTime;

  const DetailedRestaurantInformationSection({
    super.key,
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
          Text("AI-Generated Summary",
            style: GoogleFonts.lato(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            restaurantGenerativeSummary ??
                "There is not a generative summary for this restaurant",
            style: GoogleFonts.lato(
              color: const Color.fromARGB(255, 32, 32, 32),
              fontSize: 16,
              
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: CupertinoIcons.location,
            title: "Address",
            content: restaurantFormattedaddress ?? "Address not available",
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: CupertinoIcons.clock,
            title: "Opening Hours",
            content: restaurantNextCloseTime ?? "Unknown",
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: CupertinoIcons.phone,
            title: "Phone",
            content:
                restaurantInternationalPhoneNumber ?? "Phone not available",
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
                style: GoogleFonts.lato(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.lato(
                  color: const Color.fromARGB(255, 80, 80, 80),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DetailedRestaurantCommentsSection extends StatelessWidget {
  final List<dynamic>? restaurantReviews;

  const DetailedRestaurantCommentsSection({
    super.key,
    this.restaurantReviews,
  });

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
            "User Reviews",
            style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Text(
              "No reviews available for this restaurant.",
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            )
          else
            ...reviews.map((r) => _buildReviewCard(r)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
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
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.lato(
                  fontSize: 13,
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
                index < rating ? Icons.star_border_purple500_rounded : Icons.star_border,
                color: const Color.fromARGB(255, 221, 133, 2),
                size: 20,
              );
            }),
          ),

          const SizedBox(height: 8),

          // Yorum
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}


