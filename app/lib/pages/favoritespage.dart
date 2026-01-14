import 'package:flutter/material.dart';
import 'package:app/database/entity/favorite.dart';
import 'package:app/pages/detailedrestaurantpage.dart';
import 'package:app/database/database.dart';
import 'package:app/database/services/localdbservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:app/services/favoritesservice.dart';
import 'package:provider/provider.dart';
import 'package:app/global/universaltheme.dart';

// BURADA OLAN SAYFALAR SAHTE SADECE AKIŞI DENEMEK İÇİN
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Favorite> _favorites = [];
  AppDataBase? _db;
  String? _userId;
  bool _isLoading = false;
 

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

    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_isLoading) return;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    if (_db == null || _userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final favorites = _userId!.isNotEmpty
          ? await _db!.favoritesDao.getAllFavorites(_userId!)
          : <Favorite>[];
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favoriler yüklenirken hata oluştu: $e')),
        );
      }
      return;
    } finally {
      if (mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFavorite(Favorite fav) async {
    if (_db == null || _userId == null || _userId!.isEmpty) return;

    try {
      await _db!.favoritesDao.deleteFavorite(fav.id);
      await GetIt.I<FavoritesService>().deleteFavorite(fav.id);

      if (!mounted) return;
      setState(() {
        _favorites.removeWhere((favorite) => favorite.id == fav.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favori silinirken hata oluştu: $e')),
        );
      }
    }
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
      _removeFavorite(favorite);
    }
  }


  @override
  Widget build(BuildContext context) {
    final bottomTab = Provider.of<BottomTabState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadFavorites,
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
                                    errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image_not_supported),
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
                            onTap: () async{
                             if (_db == null) return;
                                    final place = await _db!.placeDao.getPlaceById(fav.placeId);
                                    if (!mounted) return;
                                    if (place == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Mekan bilgisi bulunamadı")),
                                      );
                                      return;
                                    }
                                    if (mounted) {
                                      bottomTab.navigatorKey.currentState!.pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => DetailedRestaurantPage(
                                            place: place,
                                          ),
                                        ),
                                      );
                                    }
                              },
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