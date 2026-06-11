import 'package:flutter/material.dart';
import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:go_router/go_router.dart';

class ModuleAScreen extends StatelessWidget {
  final ThemeService themeService;

  const ModuleAScreen({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: theme.buttonBackground,
        foregroundColor: theme.buttonForeground,
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          tooltip: 'Về trang chủ',
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'MÀN HÌNH MODULE A',
          style: TextStyle(
            fontFamily: theme.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: theme.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.cardRadius),
                side: BorderSide(color: theme.inputBorder, width: 1.5),
              ),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin Theme hiện tại (Module A)',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: theme.fontSize + 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _buildThemeInfoRow('Font Family', theme.fontFamily),
                    _buildThemeInfoRow('Font Size', '${theme.fontSize} sp'),
                    _buildThemeInfoRow('Card Radius', '${theme.cardRadius} dp'),
                    _buildThemeInfoRow('Button Radius', '${theme.buttonRadius} dp'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Controls
            Text(
              'ĐỔI PHÂN KHÚC THEME (SEGMENT)',
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      themeService.applyForUser(const UserContext(segment: 'STANDARD'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonBackground,
                      foregroundColor: theme.buttonForeground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(theme.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: Text(
                      'Standard Theme',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      themeService.applyForUser(const UserContext(segment: 'VIP'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonBackground,
                      foregroundColor: theme.buttonForeground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(theme.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: Text(
                      'VIP Theme',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            
            // Helpful Guide
            Text(
              'Mẹo: Nhấn nút VIP Theme ở trên rồi chuyển sang tab Module B bằng thanh điều hướng bên dưới để kiểm tra xem Module B đã được tự động cập nhật theme chưa.',
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: 12.0,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: theme.buttonBackground,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontFamily: theme.fontFamily, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontFamily: theme.fontFamily),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_one),
            label: 'Module A',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_two),
            label: 'Module B',
          ),
        ],
        onTap: (index) {
          if (index == 1) context.go('/module_b');
        },
      ),
    );
  }

  Widget _buildThemeInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12.0)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
        ],
      ),
    );
  }
}
