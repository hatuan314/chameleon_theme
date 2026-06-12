import 'dart:convert';
import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeTestScreen extends StatefulWidget {
  final ThemeService themeService;

  const ThemeTestScreen({super.key, required this.themeService});

  @override
  State<ThemeTestScreen> createState() => _ThemeTestScreenState();
}

class _ThemeTestScreenState extends State<ThemeTestScreen> {
  final ConfigService _configService = ConfigService();

  // Selected Tenant / Segment states
  String _selectedTenant = 'xbank';
  String _selectedSegment = 'STANDARD';

  final TextEditingController _jsonConfigController = TextEditingController();
  String? _validationErrorText;

  // Local sandbox configurations (pre-loaded from the active theme)
  late Color _buttonBackground;
  late Color _buttonForeground;
  late Color _cardSurface;
  late Color _inputBorder;
  late double _buttonRadius;
  late double _cardRadius;
  late double _fontSize;
  late double _fontWeight;
  late String _fontFamily;

  // Custom configuration variables
  late bool _enablePromo;
  late Color _promoBannerBg;

  // Color presets for interactive editing
  final List<Color> _bgPresets = [
    const Color(0xFF005BAC), // XBank default blue
    const Color(0xFFD4AF37), // VIP Gold
    const Color(0xFF1B5E20), // Forest Green
    const Color(0xFFB71C1C), // Crimson Red
    const Color(0xFF4A148C), // Royal Purple
    const Color(0xFF006064), // Deep Teal
    const Color(0xFFE65100), // Burnt Orange
    const Color(0xFF212121), // Charcoal
  ];

  final List<Color> _fgPresets = [
    Colors.white,
    Colors.black,
    const Color(0xFFFFD700), // Bright Gold
    const Color(0xFFE0E0E0), // Light Grey
  ];

  final List<String> _fontPresets = [
    'Inter',
    'Playfair Display',
    'Roboto',
    'Courier',
    'System',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromActiveTheme();
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
      // Failed to load or format
    }
  }

  void _loadFromActiveTheme() {
    final theme = widget.themeService.current;
    _buttonBackground = theme.buttonBackground;
    _buttonForeground = theme.buttonForeground;
    _cardSurface = theme.cardSurface;
    _inputBorder = theme.inputBorder;
    _buttonRadius = theme.buttonRadius;
    _cardRadius = theme.cardRadius;
    _fontSize = theme.fontSize;
    _fontWeight = theme.fontWeight;
    _fontFamily = theme.fontFamily;

    // Load custom params
    _enablePromo = theme.customValue<bool>('enablePromo') ?? false;
    _promoBannerBg = theme.customColor('promoBannerBg') ?? Colors.orange;
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
        _loadFromActiveTheme();
      });
      await _loadJsonFromAsset(tenantKey);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi load cấu hình Tenant: $e')),
      );
    }
  }

  void _switchSegment(String segment) {
    widget.themeService.applyForUser(UserContext(segment: segment));
    setState(() {
      _selectedSegment = segment;
      _loadFromActiveTheme();
    });
  }

  void _applyCustomSandboxTheme() {
    final customTheme = AppTheme(
      buttonBackground: _buttonBackground,
      buttonForeground: _buttonForeground,
      cardSurface: _cardSurface,
      inputBorder: _inputBorder,
      cardRadius: _cardRadius,
      buttonRadius: _buttonRadius,
      fontFamily: _fontFamily,
      fontWeight: _fontWeight,
      fontSize: _fontSize,
      custom: {
        'enablePromo': _enablePromo,
        'promoBannerBg': '#${_promoBannerBg.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      },
    );
    widget.themeService.applyCustomTheme(customTheme);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã áp dụng theme tùy chỉnh thành công!'),
        duration: Duration(seconds: 1),
      ),
    );
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
        _loadFromActiveTheme();
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
    showDialog(
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
    // We listen to the themeService globally as well
    return ListenableBuilder(
      listenable: widget.themeService,
      builder: (context, child) {
        final activeTheme = widget.themeService.current;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Theme Testing Sandbox'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Khôi phục theme mặc định',
                onPressed: () {
                  setState(() {
                    _loadFromActiveTheme();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đồng bộ lại từ cấu hình hệ thống')),
                  );
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              final previewSection = _buildPreviewSection(activeTheme);
              final controlSection = _buildControlSection(activeTheme);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: previewSection,
                      ),
                    ),
                    const VerticalDivider(width: 1.0, thickness: 1.0),
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: controlSection,
                      ),
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        previewSection,
                        const SizedBox(height: 24.0),
                        const Divider(height: 1.0, thickness: 1.0),
                        const SizedBox(height: 24.0),
                        controlSection,
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPreviewSection(AppTheme activeTheme) {
    // Current Preview is rendered using local sandbox values so changes show live before clicking 'Apply'
    final localTheme = AppTheme(
      buttonBackground: _buttonBackground,
      buttonForeground: _buttonForeground,
      cardSurface: _cardSurface,
      inputBorder: _inputBorder,
      cardRadius: _cardRadius,
      buttonRadius: _buttonRadius,
      fontFamily: _fontFamily,
      fontWeight: _fontWeight,
      fontSize: _fontSize,
      custom: {
        'enablePromo': _enablePromo,
        'promoBannerBg': '#${_promoBannerBg.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
      },
    );

    return Theme(
      data: ThemeData(
        extensions: [localTheme],
      ),
      child: Builder(
        builder: (localContext) {
          final t = localContext.appTheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MÀN HÌNH XEM TRƯỚC (PREVIEW)',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),

              // Promo Banner Sandbox
              if (t.customValue<bool>('enablePromo') ?? false)
                Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: t.customColor('promoBannerBg') ?? Colors.orange,
                    borderRadius: BorderRadius.circular(t.buttonRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Sandbox Promo: Nhận ngay ưu đãi khi kích hoạt sandbox!',
                          style: TextStyle(
                            fontFamily: t.fontFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Card Container
              Card(
                color: t.cardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(t.cardRadius),
                  side: BorderSide(color: t.inputBorder, width: 2.0),
                ),
                elevation: 6.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Demo Card Title',
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: t.fontSize + 4.0,
                          fontWeight: t.fontWeight == 700.0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Đây là nội dung thử nghiệm để kiểm tra sự hiển thị của font size, font family và font weight khi thay đổi cấu hình theme.',
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: t.fontSize,
                          fontWeight: t.fontWeight == 700.0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Input Text Box
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Input Test Field',
                          labelStyle: TextStyle(
                            fontFamily: t.fontFamily,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: t.inputBorder, width: 1.5),
                            borderRadius: BorderRadius.circular(t.buttonRadius),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: t.buttonBackground, width: 2.0),
                            borderRadius: BorderRadius.circular(t.buttonRadius),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Interactive Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.buttonBackground,
                          foregroundColor: t.buttonForeground,
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(t.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        child: Text(
                          'Test Button',
                          style: TextStyle(
                            fontFamily: t.fontFamily,
                            fontSize: t.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              
              // Meta info
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông số kỹ thuật của Sandbox:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      _buildTokenValueRow('Button Bg', '#${t.buttonBackground.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                      _buildTokenValueRow('Button Fg', '#${t.buttonForeground.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                      _buildTokenValueRow('Card Surface', '#${t.cardSurface.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                      _buildTokenValueRow('Card Radius', '${t.cardRadius.toStringAsFixed(1)} dp'),
                      _buildTokenValueRow('Button Radius', '${t.buttonRadius.toStringAsFixed(1)} dp'),
                      _buildTokenValueRow('Font Family', t.fontFamily),
                      _buildTokenValueRow('Font Size', '${t.fontSize.toStringAsFixed(1)} sp'),
                      _buildTokenValueRow('Font Weight', t.fontWeight.toString()),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildTokenValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.0, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildControlSection(AppTheme activeTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'BẢNG ĐIỀU KHIỂN (THEME CONTROLS)',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16.0),

        // 1. Tenant/Segment Selector (Global business themes)
        _buildSectionHeader('1. Cấu hình Tenant & Segment (Hệ thống)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tenant (Ngân hàng):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    _buildSwitchButton(
                      label: 'XBank',
                      isSelected: _selectedTenant == 'xbank',
                      onPressed: () => _switchTenant('xbank'),
                    ),
                    const SizedBox(width: 12.0),
                    _buildSwitchButton(
                      label: 'NewBank',
                      isSelected: _selectedTenant == 'newbank',
                      onPressed: () => _switchTenant('newbank'),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Text('Phân khúc người dùng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    _buildSwitchButton(
                      label: 'Standard',
                      isSelected: _selectedSegment == 'STANDARD',
                      onPressed: () => _switchSegment('STANDARD'),
                    ),
                    const SizedBox(width: 12.0),
                    _buildSwitchButton(
                      label: 'VIP',
                      isSelected: _selectedSegment == 'VIP',
                      onPressed: () => _switchSegment('VIP'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // 2. Custom Token Modifiers (Sandbox)
        _buildSectionHeader('2. Tùy chỉnh màu sắc (Colors Sandbox)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorPresetPicker('Màu nền nút bấm (Button Background):', _buttonBackground, (color) {
                  setState(() => _buttonBackground = color);
                }),
                const Divider(),
                _buildColorPresetPicker('Màu chữ nút bấm (Button Foreground):', _buttonForeground, (color) {
                  setState(() => _buttonForeground = color);
                }),
                const Divider(),
                _buildColorPresetPicker('Màu nền thẻ (Card Surface):', _cardSurface, (color) {
                  setState(() => _cardSurface = color);
                }),
                const Divider(),
                _buildColorPresetPicker('Màu viền nhập liệu (Input Border):', _inputBorder, (color) {
                  setState(() => _inputBorder = color);
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // 3. Spacing / Radii Modifiers
        _buildSectionHeader('3. Tùy chỉnh bo góc (Radii Sandbox)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildSliderRow(
                  label: 'Bo góc nút bấm (Button Radius)',
                  value: _buttonRadius,
                  min: 0.0,
                  max: 30.0,
                  onChanged: (val) => setState(() => _buttonRadius = val),
                ),
                const Divider(),
                _buildSliderRow(
                  label: 'Bo góc thẻ (Card Radius)',
                  value: _cardRadius,
                  min: 0.0,
                  max: 30.0,
                  onChanged: (val) => setState(() => _cardRadius = val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // 4. Typography Modifiers
        _buildSectionHeader('4. Tùy chỉnh kiểu chữ (Typography Sandbox)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildSliderRow(
                  label: 'Cỡ chữ (Font Size)',
                  value: _fontSize,
                  min: 10.0,
                  max: 30.0,
                  onChanged: (val) => setState(() => _fontSize = val),
                ),
                const Divider(),
                _buildSliderRow(
                  label: 'Độ đậm chữ (Font Weight)',
                  value: _fontWeight,
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  onChanged: (val) => setState(() => _fontWeight = val),
                ),
                const Divider(),
                _buildDropdownRow('Font Family', _fontFamily, _fontPresets, (val) {
                  if (val != null) setState(() => _fontFamily = val);
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // 5. Custom Attributes Sandbox
        _buildSectionHeader('5. Cấu hình bổ sung (Custom Config)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Bật Banner quảng cáo (enablePromo)', style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
                  value: _enablePromo,
                  activeThumbColor: activeTheme.buttonBackground,
                  activeTrackColor: activeTheme.buttonBackground.withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _enablePromo = val),
                ),
                if (_enablePromo) ...[
                  const Divider(),
                  _buildColorPresetPicker('Màu nền banner quảng cáo (promoBannerBg):', _promoBannerBg, (color) {
                    setState(() => _promoBannerBg = color);
                  }),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        // 6. Direct JSON Config Editor
        _buildSectionHeader('6. Chỉnh sửa cấu hình JSON trực tiếp (Dynamic JSON Load)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nhập và chỉnh sửa JSON cấu hình theme bên dưới. Hệ thống sẽ sử dụng ConfigValidator để kiểm tra tính hợp lệ trước khi áp dụng.',
                  style: TextStyle(fontSize: 12.0, color: Colors.black54),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: _jsonConfigController,
                  maxLines: 12,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12.0),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Nhập JSON cấu hình theme tại đây...',
                    fillColor: Colors.grey[50],
                    filled: true,
                    errorText: _validationErrorText != null ? 'Có lỗi validation (Xem chi tiết bên dưới)' : null,
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
                      style: TextStyle(color: Colors.red[900], fontSize: 12.0, fontFamily: 'Courier'),
                    ),
                  ),
                ],
                const SizedBox(height: 12.0),
                ElevatedButton.icon(
                  onPressed: _applyJsonConfig,
                  icon: const Icon(Icons.bolt),
                  label: const Text('VALIDATE & ÁP DỤNG JSON DỰNG SẴN', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        // Action Buttons
        ElevatedButton.icon(
          onPressed: _applyCustomSandboxTheme,
          icon: const Icon(Icons.check),
          label: const Text('ÁP DỤNG LÊN TOÀN BỘ APP', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        const SizedBox(height: 12.0),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _loadFromActiveTheme();
            });
          },
          icon: const Icon(Icons.undo),
          label: const Text('KHÔI PHỤC THEME HIỆN TẠI'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red[700],
            side: BorderSide(color: Colors.red[700]!),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.black54),
      ),
    );
  }

  Widget _buildSwitchButton({required String label, required bool isSelected, required VoidCallback onPressed}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? widget.themeService.current.buttonBackground.withValues(alpha: 0.1) : Colors.transparent,
          side: BorderSide(
            color: isSelected ? widget.themeService.current.buttonBackground : Colors.grey,
            width: isSelected ? 2.0 : 1.0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? widget.themeService.current.buttonBackground : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPresetPicker(String label, Color currentColor, ValueChanged<Color> onSelected) {
    final List<Color> mergedPresets = {..._bgPresets, ..._fgPresets}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 36.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mergedPresets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8.0),
            itemBuilder: (context, index) {
              final color = mergedPresets[index];
              final isSelected = color.toARGB32() == currentColor.toARGB32();

              return GestureDetector(
                onTap: () => onSelected(color),
                child: Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: isSelected ? 3.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.5), blurRadius: 4.0)]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          size: 16.0,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
            Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: widget.themeService.current.buttonBackground,
          inactiveColor: widget.themeService.current.buttonBackground.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
