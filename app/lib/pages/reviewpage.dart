import 'package:flutter/material.dart';
import 'package:app/database/entity/review.dart';
//import 'restaurant_main_page.dart';
import 'package:app/pages/detailedrestaurantpage.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadDummyReviews();
  }

  
  // Dummy data
 
  void _loadDummyReviews() {
    _reviews = [
      Review(
        id: '1',
        userId: 'u1',
        placeId: 'p1',
        placeName: 'Kahve Durağı',
        placeAddress: 'Kadıköy / İstanbul',
        rating: 5,
        comment: 'Harika bir yer!',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
      Review(
        id: '2',
        userId: 'u1',
        placeId: 'p2',
        placeName: 'Pizza House',
        placeAddress: 'Beşiktaş / İstanbul',
        rating: 4,
        comment: 'Lezzetli ama biraz pahalı.',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
  }

 
  // Refresh (güncelle)
  
  Future<void> _refreshReviews() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadDummyReviews();
    });
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
      setState(() {
        _reviews.removeWhere((r) => r.id == review.id);
      });
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
      setState(() {
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _reviews[index] = Review(
            id: review.id,
            userId: review.userId,
            placeId: review.placeId,
            placeName: review.placeName,
            placeAddress: review.placeAddress,
            rating: selectedRating,
            comment: commentController.text,
            createdAt: review.createdAt,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
        }
      });
    }
  }

  
  // UI
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorumlarım'),
        /* actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReviews,
          ),
        ], */
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReviews,
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
              onTap: () {
                /* Navigator.push(
                   context,
                  MaterialPageRoute(
                    builder: (_) => DetailedRestaurantPage(
                      placeId: review.placeId,
                      placeName: review.placeName,
                      placeAddress: review.placeAddress,
                    ),
                  ), 
                ); */
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
    );

    
  }
}
