import 'package:flutter/material.dart';
import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: theme.buttonBackground,
        foregroundColor: theme.buttonForeground,
        title: Text(
          'CHAMELEON MONOREPO',
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
            const SizedBox(height: 8.0),

            // Info Banner
            Card(
              color: theme.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.cardRadius),
                side: BorderSide(color: theme.inputBorder, width: 1.0),
              ),
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 40.0,
                      color: theme.buttonBackground,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Monorepo Theme Engine',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: theme.fontSize + 4.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Mỗi module là một package riêng biệt. Switch theme từ bất kỳ màn hình nào sẽ cập nhật toàn bộ app ngay lập tức.',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            Text(
              'CHỌN MODULE ĐỂ KIỂM THỬ',
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),

            // Module A Card
            _ModuleNavCard(
              icon: Icons.looks_one_rounded,
              title: 'Module A',
              description: 'Hiển thị thông tin theme đang áp dụng. Có thể switch sang Standard / VIP.',
              onTap: () => context.go('/module_a'),
              buttonBackground: theme.buttonBackground,
              buttonForeground: theme.buttonForeground,
              cardSurface: theme.cardSurface,
              cardRadius: theme.cardRadius,
              inputBorder: theme.inputBorder,
              fontFamily: theme.fontFamily,
              fontSize: theme.fontSize,
            ),

            const SizedBox(height: 12.0),

            // Module B Card
            _ModuleNavCard(
              icon: Icons.looks_two_rounded,
              title: 'Module B',
              description: 'Hiển thị tài khoản & số dư. Có thể switch sang Standard / VIP.',
              onTap: () => context.go('/module_b'),
              buttonBackground: theme.buttonBackground,
              buttonForeground: theme.buttonForeground,
              cardSurface: theme.cardSurface,
              cardRadius: theme.cardRadius,
              inputBorder: theme.inputBorder,
              fontFamily: theme.fontFamily,
              fontSize: theme.fontSize,
            ),

            const SizedBox(height: 32.0),

            // Quick switch section
            Text(
              'QUICK SWITCH THEME',
              style: TextStyle(
                fontFamily: theme.fontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => themeService.applyForUser(const UserContext(segment: 'STANDARD')),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.buttonBackground),
                      foregroundColor: theme.buttonBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(theme.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: Text(
                      'Standard',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => themeService.applyForUser(const UserContext(segment: 'VIP')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonBackground,
                      foregroundColor: theme.buttonForeground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(theme.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                    ),
                    child: Text(
                      'VIP',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _ModuleNavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color buttonBackground;
  final Color buttonForeground;
  final Color cardSurface;
  final double cardRadius;
  final Color inputBorder;
  final String fontFamily;
  final double fontSize;

  const _ModuleNavCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.cardSurface,
    required this.cardRadius,
    required this.inputBorder,
    required this.fontFamily,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: inputBorder, width: 1.0),
      ),
      elevation: 3.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: buttonBackground.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: buttonBackground, size: 28.0),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: fontSize + 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 11.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: buttonBackground),
            ],
          ),
        ),
      ),
    );
  }
}
