import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConfigService _configService = ConfigService();
  final TextEditingController _jsonConfigController = TextEditingController();
  String _selectedTenant = 'xbank';
  String _selectedSegment = 'STANDARD';
  String? _validationErrorText;

  @override
  void initState() {
    super.initState();
    _loadJsonFromAsset(_selectedTenant);
  }

  @override
  void dispose() {
    _jsonConfigController.dispose();
    super.dispose();
  }

  Future<void> _loadJsonFromAsset(String tenantKey) async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/chameleon_theme/assets/configs/tenants/$tenantKey.json',
      );
      final dynamic decoded = json.decode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(decoded);
      if (!mounted) return;
      setState(() {
        _jsonConfigController.text = prettyJson;
        _validationErrorText = null;
      });
    } catch (e) {
      // Failed to load
    }
  }

  Future<void> _switchTenant(String tenantKey) async {
    try {
      final jsonString = await rootBundle.loadString(
        'packages/chameleon_theme/assets/configs/tenants/$tenantKey.json',
      );
      final config = await _configService.loadFromJsonString(jsonString);
      final registry = TenantThemeRegistry.fromConfig(
        config,
        tenantKey: tenantKey,
      );
      widget.themeService.registry = registry;
      widget.themeService.applyForUser(UserContext(segment: _selectedSegment));
      if (!mounted) return;
      setState(() {
        _selectedTenant = tenantKey;
      });
      await _loadJsonFromAsset(tenantKey);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi load cấu hình Tenant: $e')),
      );
    }
  }

  Future<void> _applyJsonConfig() async {
    final rawJson = _jsonConfigController.text.trim();
    if (rawJson.isEmpty) {
      setState(() {
        _validationErrorText = 'JSON không được để trống';
      });
      return;
    }

    try {
      final config = await _configService.loadFromJsonString(rawJson);
      final registry = TenantThemeRegistry.fromConfig(
        config,
        tenantKey: 'custom_dynamic',
      );
      widget.themeService.registry = registry;
      widget.themeService.applyForUser(UserContext(segment: _selectedSegment));
      
      if (!mounted) return;
      setState(() {
        _selectedTenant = 'custom';
        _validationErrorText = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã kiểm tra (Validate) và áp dụng cấu hình JSON thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _validationErrorText = 'Lỗi cú pháp JSON:\n$e';
      });
    } on ValidationException catch (e) {
      if (!mounted) return;
      final errorsBuffer = StringBuffer('Cấu hình JSON không hợp lệ:\n');
      for (final error in e.errors) {
        errorsBuffer.writeln('- $error');
      }
      setState(() {
        _validationErrorText = errorsBuffer.toString();
      });
      _showErrorDialog(e.errors);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _validationErrorText = 'Lỗi không xác định: $e';
      });
    }
  }

  void _showErrorDialog(List<String> errors) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8.0),
              Text('Lỗi Validation Config'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Phát hiện các lỗi ràng buộc cấu hình sau đây:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                ...errors.map((error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(fontFamily: 'Courier', fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

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
                    onPressed: () {
                      widget.themeService.applyForUser(const UserContext(segment: 'STANDARD'));
                      setState(() {
                        _selectedSegment = 'STANDARD';
                      });
                    },
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
                    onPressed: () {
                      widget.themeService.applyForUser(const UserContext(segment: 'VIP'));
                      setState(() {
                        _selectedSegment = 'VIP';
                      });
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
            const SizedBox(height: 24.0),

            // Dynamic JSON Config Editor Section
            Text(
              'DYNAMIC CONFIG LOADING (002-JSON-CONFIG-LOADING)',
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
            Card(
              color: theme.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.cardRadius),
                side: BorderSide(color: theme.inputBorder, width: 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chọn file mẫu:',
                          style: TextStyle(fontFamily: theme.fontFamily, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _switchTenant('xbank'),
                              child: Text('xbank', style: TextStyle(fontWeight: _selectedTenant == 'xbank' ? FontWeight.bold : FontWeight.normal)),
                            ),
                            TextButton(
                              onPressed: () => _switchTenant('newbank'),
                              child: Text('newbank', style: TextStyle(fontWeight: _selectedTenant == 'newbank' ? FontWeight.bold : FontWeight.normal)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _jsonConfigController,
                      maxLines: 8,
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 12.0),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'JSON Theme Config String',
                        labelStyle: TextStyle(fontFamily: theme.fontFamily),
                        fillColor: Colors.grey[50],
                        filled: true,
                        errorText: _validationErrorText != null ? 'Lỗi cấu hình' : null,
                      ),
                    ),
                    if (_validationErrorText != null) ...[
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          _validationErrorText!,
                          style: TextStyle(color: Colors.red[900], fontSize: 11.0, fontFamily: 'Courier'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12.0),
                    ElevatedButton.icon(
                      onPressed: _applyJsonConfig,
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('VALIDATE & APPLY JSON CONFIG', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.buttonBackground,
                        foregroundColor: theme.buttonForeground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(theme.buttonRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
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
