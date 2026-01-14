import 'package:app/global/universaltheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FontSettingsPage extends StatelessWidget {
  const FontSettingsPage({super.key});

  static const primaryColor = Color(0xFFFF7300);

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
            // Font Tipi Seçimi - Dropdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    'Font Tipi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: themeProvider.fontFamily,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: primaryColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        items: ThemeProvider.availableFonts.map((
                          String fontName,
                        ) {
                          return DropdownMenuItem<String>(
                            value: fontName,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.font_download,
                                  size: 20,
                                  color: themeProvider.fontFamily == fontName
                                      ? primaryColor
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  fontName,
                                  style: TextStyle(
                                    color: themeProvider.fontFamily == fontName
                                        ? primaryColor
                                        : Colors.black87,
                                    fontWeight:
                                        themeProvider.fontFamily == fontName
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            themeProvider.updateFontFamily(newValue);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seçtiğiniz font tüm uygulamada kullanılacak',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Font Boyutu Ayarlama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    'Font Boyutu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mevcut Boyut:',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${themeProvider.fontSize.toInt()}',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      Expanded(
                        child: Slider(
                          value: themeProvider.fontSize,
                          min: 10,
                          max: 13,
                          divisions: 3,
                          activeColor: primaryColor,
                          inactiveColor: primaryColor.withOpacity(0.2),
                          label: themeProvider.fontSize.toInt().toString(),
                          onChanged: (value) {
                            themeProvider.updateFontSize(value);
                          },
                        ),
                      ),
                      Icon(
                        Icons.text_fields,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Önizleme Kutusu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    children: [
                      Icon(Icons.visibility, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Önizleme',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Büyük Başlık',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Orta Başlık',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Küçük Başlık',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Normal metin Büyük',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Normal metin Orta',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Normal metin Küçük',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bu önizleme metni seçili font tipini ve boyutunu gösterir. Ayarlarınızı değiştirdikçe bu metin otomatik olarak güncellenir.',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: Colors.grey[600]),
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
