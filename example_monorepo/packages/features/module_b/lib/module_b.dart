import 'package:flutter/material.dart';
import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:go_router/go_router.dart';

class ModuleBScreen extends StatelessWidget {
  final ThemeService themeService;

  const ModuleBScreen({super.key, required this.themeService});

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
          'MÀN HÌNH MODULE B',
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
                      'Tài khoản & Số dư (Module B)',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: theme.fontSize + 2.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'đ 50,000,000',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: theme.buttonBackground,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Số dư được tạo kiểu động bằng Token màu sắc và font chữ của theme.',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
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
                      themeService.applyForUser(
                        const UserContext(segment: 'STANDARD'),
                      );
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
                      themeService.applyForUser(
                        const UserContext(segment: 'VIP'),
                      );
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

            // Promo Banner B
            if (theme.customValue<bool>('enablePromo') ?? false)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.customColor('promoBannerBg') ?? Colors.orange,
                  borderRadius: BorderRadius.circular(theme.buttonRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Tính năng Promo tùy chỉnh được đồng bộ hóa ngay lập tức sang Module B!',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: theme.buttonBackground,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontFamily: theme.fontFamily,
          fontWeight: FontWeight.bold,
        ),
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
          if (index == 0) context.go('/module_a');
        },
      ),
    );
  }
}
