import 'package:app/global/universaltheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FontSettingsPage extends StatelessWidget {
  const FontSettingsPage({super.key});

  static const primaryColor = Color.fromARGB(255, 221, 133, 2);

  BoxDecoration orangeDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: primaryColor,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.15),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Font Ayarları",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: orangeDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Tipi',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: themeProvider.fontFamily,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: primaryColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        items: ThemeProvider.availableFonts.map((font) {
                          return DropdownMenuItem<String>(
                            value: font,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.font_download,
                                  size: 20,
                                  color: themeProvider.fontFamily == font
                                      ? primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  font,
                                  style: TextStyle(
                                    color: themeProvider.fontFamily == font
                                        ? primaryColor
                                        : Colors.black,
                                    fontWeight:
                                        themeProvider.fontFamily == font
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            themeProvider.updateFontFamily(value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seçtiğiniz font tüm uygulamada kullanılacak',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: orangeDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Boyutu',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mevcut Boyut:',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          themeProvider.fontSize.toInt().toString(),
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Slider(
                    value: themeProvider.fontSize,
                    min: 10,
                    max: 13,
                    divisions: 3,
                    activeColor: primaryColor,
                    inactiveColor: primaryColor.withOpacity(0.3),
                    label: themeProvider.fontSize.toInt().toString(),
                    onChanged: (value) {
                      themeProvider.updateFontSize(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: orangeDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.visibility, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Önizleme',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Büyük Başlık',
                            style:
                                Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        Text('Orta Başlık',
                            style:
                                Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text('Küçük Başlık',
                            style:
                                Theme.of(context).textTheme.headlineSmall),
                        const Divider(),
                        Text(
                          'Normal metin örneği. Font ve boyut anlık güncellenir.',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
