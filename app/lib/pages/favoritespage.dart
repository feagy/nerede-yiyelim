import 'package:flutter/material.dart';
import 'package:app/database/entity/favorite.dart';
import 'package:app/pages/detailedrestaurantpage.dart';

// BURADA OLAN SAYFALAR SAHTE SADECE AKIŞI DENEMEK İÇİN
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  /// Dummy favori listesi
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadDummyFavorites();
  }

  /// Sahte (dummy) verileri yükler
  void _loadDummyFavorites() {
    _favorites = [
      Favorite(
        id: '1',
        placeId:'1',
        userId: '1',
        placeName: 'Kahve Durağı',
        placeAddress: 'Kadıköy / İstanbul',
        rating: 4.5,
        photoUrl: null,
      ),
      Favorite(
        id: '2',
        placeId:'2',
        userId: '1',
        placeName: 'Pizza House',
        placeAddress: 'Beşiktaş / İstanbul',
        rating: 4.0,
        photoUrl: null,
      ),
      Favorite(
        id: '3',
        placeId:'3',
        userId: '1',
        placeName: 'Burger Point',
        placeAddress: 'Şişli / İstanbul',
        rating: null,
        photoUrl: null,
      ),
    ];
  }

  /// Aşağı çekerek yenileme (simülasyon)
  Future<void> _refreshFavorites() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadDummyFavorites();
    });
  }

  /// Favori silme
  void _removeFavorite(String id) {
    setState(() {
      _favorites.removeWhere((fav) => fav.id == id);
    });
  }



// Delete confirmation
  
  Future<void> _confirmDelete(Favorite favorite) async {
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
        _favorites.removeWhere((r) => r.id == favorite.id);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: _favorites.isEmpty
            ? const Center(
                child: Text('Henüz favori yok'),
              )
            : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final fav = _favorites[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: fav.photoUrl != null
                          ? Image.network(
                              fav.photoUrl!,
                              width: 60,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                      title: Text(
                        fav.placeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fav.placeAddress),
                          if (fav.rating != null)
                            Text('⭐ ${fav.rating}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(fav), 
                          
                        
                      ),
                      onTap: () {
                       /* Navigator.push(
                       context,
                        MaterialPageRoute(
                        builder: (context) => DetailedRestaurantPage(
                        favorite: fav,
                              ),
                            ),
                          ); */
                        },
                    ),
                  );
                },
              ),
      ),
    );
  }
}






/* class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  /// Dummy favori listesi
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadDummyFavorites();
  }

  /// Dummy verileri yükler
  void _loadDummyFavorites() {
    _favorites = [
      Favorite(
        id: '1',
        placeName: 'Kahve Durağı',
        placeAddress: 'Kadıköy / İstanbul',
        rating: 4.5,
      ),
      Favorite(
        id: '2',
        placeName: 'Pizza House',
        placeAddress: 'Beşiktaş / İstanbul',
        rating: 4.0,
      ),
      Favorite(
        id: '3',
        placeName: 'Burger Point',
        placeAddress: 'Şişli / İstanbul',
      ),
    ];
  }

  /// Aşağı çekerek yenileme (simülasyon)
  Future<void> _refreshFavorites() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadDummyFavorites();
    });
  }

  /// Favori silme
  void _removeFavorite(String id) {
    setState(() {
      _favorites.removeWhere((fav) => fav.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: _favorites.isEmpty
            ? const Center(
                child: Text('Henüz favori yok'),
              )
            : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final fav = _favorites[index];

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: fav.photoUrl != null
                          ? Image.network(
                              fav.photoUrl!,
                              width: 60,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                      title: Text(
                        fav.placeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fav.placeAddress),
                          if (fav.rating != null)
                            Text('⭐ ${fav.rating}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _removeFavorite(fav.id);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
 */



//favorites_provider.dart ile çalışan kod
 /* import 'package:flutter/material.dart';


class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    //final provider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: RefreshIndicator(
        //onRefresh: provider.loadFavorites,
        child: ListView.builder(
          //itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            //final fav = provider.favorites[index];

            return Card(
              child: ListTile(
                leading: fav.photoUrl != null
                    ? Image.network(fav.photoUrl!, width: 60)
                    : const Icon(Icons.favorite),
                title: Text(fav.placeName),
                subtitle: Text(fav.placeAddress),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    provider.deleteFavorite(fav);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}             
 */