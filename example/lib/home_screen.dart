import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:chameleon_theme_example/theme_test_screen.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final ThemeService themeService;

  const MyHomePage({super.key, required this.themeService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ConfigService _configService = ConfigService();
  String _currentTenant = 'xbank';
  String _currentSegment = 'STANDARD';
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _switchTenant(String tenantKey) async {
    try {
      final config = await _configService.load(tenantKey);
      final registry = TenantThemeRegistry.fromConfig(
        config,
        tenantKey: tenantKey,
      );
      widget.themeService.registry = registry;
      widget.themeService.applyForUser(UserContext(segment: _currentSegment));
      if (!mounted) return;
      setState(() {
        _currentTenant = tenantKey;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi load tenant config: $e')));
    }
  }

  void _switchSegment(String segment) {
    widget.themeService.applyForUser(UserContext(segment: segment));
    setState(() {
      _currentSegment = segment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    // Check custom tokens if present (User Story 4)
    final bool enablePromo = theme.customValue<bool>('enablePromo') ?? false;
    final Color promoBgColor =
        theme.customColor('promoBannerBg') ?? Colors.orange;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: theme.buttonBackground,
        title: Text(
          'Ngân Hàng $_currentTenant'.toUpperCase(),
          style: TextStyle(
            fontFamily: theme.fontFamily,
            fontWeight: theme.fontWeight == 700.0
                ? FontWeight.bold
                : FontWeight.normal,
            color: theme.buttonForeground,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ThemeTestScreen(
                    themeService: widget.themeService,
                  ),
                ),
              );
            },
            tooltip: 'Thử nghiệm Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Promo Banner if enabled via custom tenant configs
              if (enablePromo)
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: promoBgColor,
                    borderRadius: BorderRadius.circular(theme.buttonRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _currentSegment == 'VIP'
                              ? 'Ưu đãi đặc quyền dành riêng cho khách hàng VIP!'
                              : 'Ưu đãi hấp dẫn đang chờ bạn khám phá!',
                          style: TextStyle(
                            fontFamily: theme.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Main Balance Card
              Card(
                color: theme.cardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.cardRadius),
                  side: BorderSide(color: theme.inputBorder, width: 1.5),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TÀI KHOẢN THANH TOÁN',
                            style: TextStyle(
                              fontFamily: theme.fontFamily,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: _currentSegment == 'VIP'
                                  ? theme.buttonBackground
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              _currentSegment,
                              style: TextStyle(
                                fontFamily: theme.fontFamily,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: _currentSegment == 'VIP'
                                    ? theme.buttonForeground
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _currentSegment == 'VIP'
                            ? 'đ 1,250,450,080'
                            : 'đ 12,450,080',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: _currentSegment == 'VIP'
                              ? theme.buttonBackground
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Số dư khả dụng',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontSize: 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Counter Demo Section
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Số lần bạn đã nhấn nút dưới đây:',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontSize: theme.fontSize,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '$_counter',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontSize: theme.fontSize + 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _incrementCounter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.buttonBackground,
                          foregroundColor: theme.buttonForeground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              theme.buttonRadius,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12.0,
                          ),
                        ),
                        child: Text(
                          'Tăng Số Lượng',
                          style: TextStyle(
                            fontFamily: theme.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Admin Control Panel
              Text(
                'BẢNG ĐIỀU KHIỂN CHAMELEON ENGINE',
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tenant Switcher
                      Text(
                        'Chọn Tenant (Ngân Hàng):',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _switchTenant('xbank'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _currentTenant == 'xbank'
                                      ? theme.buttonBackground
                                      : Colors.grey,
                                  width: _currentTenant == 'xbank' ? 2.0 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'XBank',
                                style: TextStyle(
                                  color: _currentTenant == 'xbank'
                                      ? theme.buttonBackground
                                      : Colors.black,
                                  fontWeight: _currentTenant == 'xbank'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _switchTenant('newbank'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _currentTenant == 'newbank'
                                      ? theme.buttonBackground
                                      : Colors.grey,
                                  width: _currentTenant == 'newbank'
                                      ? 2.0
                                      : 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'NewBank',
                                style: TextStyle(
                                  color: _currentTenant == 'newbank'
                                      ? theme.buttonBackground
                                      : Colors.black,
                                  fontWeight: _currentTenant == 'newbank'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24.0),

                      // Segment Switcher
                      Text(
                        'Chọn Phân Khúc Người Dùng:',
                        style: TextStyle(
                          fontFamily: theme.fontFamily,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _switchSegment('STANDARD'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _currentSegment == 'STANDARD'
                                      ? theme.buttonBackground
                                      : Colors.grey,
                                  width: _currentSegment == 'STANDARD'
                                      ? 2.0
                                      : 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Standard',
                                style: TextStyle(
                                  color: _currentSegment == 'STANDARD'
                                      ? theme.buttonBackground
                                      : Colors.black,
                                  fontWeight: _currentSegment == 'STANDARD'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _switchSegment('VIP'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _currentSegment == 'VIP'
                                      ? theme.buttonBackground
                                      : Colors.grey,
                                  width: _currentSegment == 'VIP' ? 2.0 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'VIP',
                                style: TextStyle(
                                  color: _currentSegment == 'VIP'
                                      ? theme.buttonBackground
                                      : Colors.black,
                                  fontWeight: _currentSegment == 'VIP'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ThemeTestScreen(
                        themeService: widget.themeService,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.tune),
                label: const Text('MỞ BẢNG ĐIỀU KHIỂN THEME SANDBOX', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.buttonBackground,
                  foregroundColor: theme.buttonForeground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(theme.buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),

              const SizedBox(height: 24.0),

              // Theme Params Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông số theme đang áp dụng:',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '• Primary Color: #${theme.buttonBackground.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}\n'
                      '• FontFamily: ${theme.fontFamily}\n'
                      '• Card Radius: ${theme.cardRadius}\n'
                      '• Button Radius: ${theme.buttonRadius}',
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: 11.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
