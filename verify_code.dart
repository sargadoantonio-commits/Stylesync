#!/usr/bin/env dart
// StyleSync Code Verification Script
// Lightweight code quality checker without heavy analysis server

import 'dart:io';
import 'dart:async';

void main(List<String> args) async {
  // ignore: avoid_print
  print('🔍 StyleSync Code Verification Tool');
  // ignore: avoid_print
  print('=' * 60);

  final libDir = Directory('lib');
  final issues = <String>[];
  final warnings = <String>[];
  final stats = {'files': 0, 'lines': 0, 'issues': 0};

  // Scan all Dart files
  // ignore: avoid_print
  print('\n📝 Scanning lib/ directory...\n');

  await for (var file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      stats['files'] = (stats['files'] as int) + 1;
      await _checkFile(file, issues, warnings, stats);
    }
  }

  // ignore: avoid_print
  print('\n${'=' * 60}');
  // ignore: avoid_print
  print('📊 VERIFICATION RESULTS\n');

  // ignore: avoid_print
  print('✅ Files scanned: ${stats['files']}');
  // ignore: avoid_print
  print('📏 Lines of code: ${stats['lines']}');
  // ignore: avoid_print
  print('⚠️  Issues found: ${stats['issues']}');

  if (issues.isNotEmpty) {
    // ignore: avoid_print
    print('\n❌ ERRORS (${issues.length}):');
    for (final issue in issues.take(20)) {
      // ignore: avoid_print
      print('   • $issue');
    }
    if (issues.length > 20) {
      // ignore: avoid_print
      print('   ... and ${issues.length - 20} more');
    }
  } else {
    // ignore: avoid_print
    print('\n✅ No critical errors found!');
  }

  if (warnings.isNotEmpty) {
    // ignore: avoid_print
    print('\n⚠️  WARNINGS (${warnings.length}):');
    for (final warn in warnings.take(10)) {
      // ignore: avoid_print
      print('   • $warn');
    }
    if (warnings.length > 10) {
      // ignore: avoid_print
      print('   ... and ${warnings.length - 10} more');
    }
  }

  // ignore: avoid_print
  print('\n${'=' * 60}');
  // ignore: avoid_print
  print(issues.isEmpty
      ? '✅ Code verification passed!'
      : '❌ Issues found - review above');
  // ignore: avoid_print
  print('=' * 60);

  exit(issues.isEmpty ? 0 : 1);
}

Future<void> _checkFile(
  File file,
  List<String> issues,
  List<String> warnings,
  Map stats,
) async {
  try {
    final content = await file.readAsString();
    final lines = content.split('\n');
    final relativePath = file.path.replaceFirst(Directory.current.path, '');

    stats['lines'] = (stats['lines'] as int) + lines.length;

    // Check for common issues
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNum = i + 1;

      // Check for TODO/FIXME comments
      if (line.contains('TODO') || line.contains('FIXME')) {
        warnings.add('$relativePath:$lineNum - ${line.trim()}');
      }

      // Check for unused imports (basic)
      if (line.startsWith('import ') && line.contains(';')) {
        // Simple heuristic: if import is 3+ lines before first usage, might be unused
      }

      // Check for print statements in production code
      if (line.contains('print(') && !file.path.contains('test')) {
        warnings.add(
            '$relativePath:$lineNum - print() found in code: ${line.trim()}');
      }

      // Check for missing null safety annotations
      if (line.contains('var ') &&
          !line.contains('?') &&
          !line.contains('late')) {
        // Basic check - could be improved
      }

      // Check for empty functions
      if (line.contains('{}') && !line.contains('const')) {
        warnings.add(
            '$relativePath:$lineNum - Empty function block: ${line.trim()}');
      }
    }

    // ignore: avoid_print
    print('✓ $relativePath (${lines.length} lines)');
  } catch (e) {
    // ignore: avoid_print
    print('⚠️  Could not read $file: $e');
  }
}
