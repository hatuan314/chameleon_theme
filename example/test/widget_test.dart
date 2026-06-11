import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chameleon_theme_example/main.dart';
import 'package:chameleon_theme/features/theme/presentation/theme_defaults.dart';
import 'package:chameleon_theme/features/theme/presentation/theme_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final themeService = ThemeService(ThemeDefaults.tokens);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(themeService: themeService));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the 'Tăng Số Lượng' button and trigger a frame.
    await tester.tap(find.text('Tăng Số Lượng'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
