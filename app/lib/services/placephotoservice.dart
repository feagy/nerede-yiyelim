import 'package:flutter_dotenv/flutter_dotenv.dart';

// Uygulamada Test Edilecek

// Image.network --> https://docs.flutter.dev/cookbook/images/network-image

// Favorilerde foto göstereceksek cache için --> https://pub.dev/packages/cached_network_image
// https://www.youtube.com/watch?v=fnHr_rsQwDA

class PlacePhotoService {
  PlacePhotoService._(this.baseUrl);
  static PlacePhotoService? _instance;
  final String baseUrl;

  factory PlacePhotoService() {
    final baseUrl = dotenv.env['PLACE_PHOTO_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('PLACE_PHOTO_URL not found in .env');
    }

    return _instance ??= PlacePhotoService._(baseUrl);
  }

  String getPhotoUrl(String photoName, int maxWidth) {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'photoName': photoName,
        'maxWidth': maxWidth.toString(),
      },
    );
    return uri.toString();
  }
}
