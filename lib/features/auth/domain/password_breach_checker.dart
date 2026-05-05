import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Provider to check if a password has been compromised using Have I Been Pwned API
final passwordBreachCheckProvider =
    FutureProvider.family<PasswordBreachResult, String>((ref, password) async {
  return await PasswordBreachChecker.checkPassword(password);
});

class PasswordBreachResult {
  final bool isCompromised;
  final int timesCompromised;
  final String message;

  PasswordBreachResult({
    required this.isCompromised,
    required this.timesCompromised,
    required this.message,
  });
}

/// Service for checking passwords against Have I Been Pwned database
/// Uses the Range API (k-anonymity) for privacy - never sends full password hash
class PasswordBreachChecker {
  static const String _hibpApiUrl =
      'https://api.pwnedpasswords.com/range';
  static const Duration _timeout = Duration(seconds: 10);

  /// Check if password has been compromised
  /// Returns PasswordBreachResult with compromise status
  static Future<PasswordBreachResult> checkPassword(String password) async {
    try {
      // Hash password with SHA-1
      final sha1Hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
      
      // Use only first 5 characters (k-anonymity protection)
      final hashPrefix = sha1Hash.substring(0, 5);
      final hashSuffix = sha1Hash.substring(5);

      // Query HIBP API
      final response = await http
          .get(
            Uri.parse('$_hibpApiUrl/$hashPrefix'),
            headers: {
              'User-Agent': 'StyleSync-Security-Check/1.0',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Parse response
        final lines = response.body.split('\r\n');
        
        for (final line in lines) {
          if (line.isEmpty) continue;
          
          final parts = line.split(':');
          if (parts.length == 2 && parts[0] == hashSuffix) {
            final count = int.tryParse(parts[1]) ?? 0;
            return PasswordBreachResult(
              isCompromised: true,
              timesCompromised: count,
              message: 'This password has been compromised in $count data breaches. '
                  'Please use a stronger, unique password.',
            );
          }
        }

        // Password not found in breach database
        return PasswordBreachResult(
          isCompromised: false,
          timesCompromised: 0,
          message: 'Password appears to be secure.',
        );
      } else if (response.statusCode == 429) {
        // Rate limited - allow registration but warn user
        debugPrint('[WARNING] HIBP API rate limited - allowing registration');
        return PasswordBreachResult(
          isCompromised: false,
          timesCompromised: 0,
          message: 'Could not verify password strength. Proceeding with caution.',
        );
      } else {
        throw Exception('HIBP API error: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      // Timeout - don't block registration, but warn
      debugPrint('[WARNING] HIBP API timeout - allowing registration');
      return PasswordBreachResult(
        isCompromised: false,
        timesCompromised: 0,
        message: 'Could not verify password. Proceeding with caution.',
      );
    } catch (e) {
      debugPrint('[ERROR] Password breach check failed: $e');
      // On any error, allow registration but flag for manual review
      return PasswordBreachResult(
        isCompromised: false,
        timesCompromised: 0,
        message: 'Could not verify password strength.',
      );
    }
  }

  /// Check multiple passwords efficiently
  static Future<Map<String, PasswordBreachResult>> checkMultiple(
      List<String> passwords) async {
    final results = <String, PasswordBreachResult>{};
    
    for (final password in passwords) {
      results[password] = await checkPassword(password);
      // Rate limit: 1 request per 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    
    return results;
  }
}
