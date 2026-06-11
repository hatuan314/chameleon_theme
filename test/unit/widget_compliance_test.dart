import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Widget files should not contain raw color literals', () {
    final libDir = Directory('lib');
    if (!libDir.existsSync()) {
      return;
    }

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        // Exclude the theme engine itself since it defines defaults and types
        .where((file) => !file.path.contains('lib/features/theme/'));

    final rawColorRegex = RegExp(r'\bColor\((0x[0-9a-fA-F]+|\d+)\)|\bColor\.fromARGB\(|\bColor\.fromRGBO\(');

    final violations = <String>[];

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Skip comments
        if (line.trim().startsWith('//') || line.trim().startsWith('/*')) {
          continue;
        }
        if (rawColorRegex.hasMatch(line)) {
          violations.add('${file.path}:${i + 1} -> $line');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Raw color literals (Color(0x...), Color.fromARGB, Color.fromRGBO) are forbidden in widget code. '
          'Please use context.appTheme or allowed constants (Colors.white/black/transparent).\n'
          'Violations found:\n${violations.join('\n')}',
    );
  });
}
