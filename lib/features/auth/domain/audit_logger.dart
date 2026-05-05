import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum AuditAction {
  login('login'),
  loginFailed('login_failed'),
  registration('registration'),
  logout('logout'),
  passwordChanged('password_changed'),
  emailVerified('email_verified'),
  mfaEnabled('mfa_enabled'),
  mfaDisabled('mfa_disabled'),
  suspiciousActivity('suspicious_activity'),
  accountLocked('account_locked'),
  passwordReset('password_reset'),
  profileUpdated('profile_updated'),
  adminActionPerformed('admin_action_performed');

  final String value;
  const AuditAction(this.value);
}

enum AuditStatus { success, failure }

class AuditLogEntry {
  final String? userId;
  final String? email;
  final AuditAction action;
  final AuditStatus status;
  final String? reason;
  final String? ipAddress;
  final String? userAgent;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  AuditLogEntry({
    this.userId,
    this.email,
    required this.action,
    required this.status,
    this.reason,
    this.ipAddress,
    this.userAgent,
    this.additionalData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'action': action.value,
      'status': status.name,
      'reason': reason,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'additionalData': additionalData,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class AuditLogger {
  static final AuditLogger _instance = AuditLogger._internal();
  
  factory AuditLogger() {
    return _instance;
  }

  AuditLogger._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Log authentication event
  Future<void> logAuthEvent({
    required String? userId,
    required String? email,
    required AuditAction action,
    required AuditStatus status,
    String? reason,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final entry = AuditLogEntry(
        userId: userId,
        email: email,
        action: action,
        status: status,
        reason: reason,
        additionalData: additionalData,
      );

      // Add to audit_logs collection
      await _firestore.collection('audit_logs').add(entry.toMap());

      // Log sensitive actions to console for real-time monitoring
      if (_isSensitiveAction(action)) {
        debugPrint(
          '[🔐 SECURITY AUDIT] ${action.value.toUpperCase()}: '
          'User=${userId ?? email} | Status=${status.name} | Reason=$reason',
        );
      }

      // Optional: Send alert for suspicious activities
      if (action == AuditAction.suspiciousActivity) {
        await _sendSecurityAlert(entry);
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to log audit event: $e');
    }
  }

  bool _isSensitiveAction(AuditAction action) {
    return [
      AuditAction.loginFailed,
      AuditAction.passwordChanged,
      AuditAction.mfaEnabled,
      AuditAction.accountLocked,
      AuditAction.suspiciousActivity,
      AuditAction.adminActionPerformed,
    ].contains(action);
  }

  Future<void> _sendSecurityAlert(AuditLogEntry entry) async {
    try {
      // Store alert for dashboard monitoring
      await _firestore.collection('security_alerts').add({
        'userId': entry.userId,
        'email': entry.email,
        'action': entry.action.value,
        'reason': entry.reason,
        'timestamp': FieldValue.serverTimestamp(),
        'acknowledged': false,
      });
    } catch (e) {
      debugPrint('[ERROR] Failed to send security alert: $e');
    }
  }

  /// Get audit logs for a specific user (admin only)
  Future<List<AuditLogEntry>> getUserAuditLogs(String userId,
      {int limit = 100}) async {
    try {
      final snapshot = await _firestore
          .collection('audit_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => _parseAuditLog(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('[ERROR] Failed to fetch user audit logs: $e');
      return [];
    }
  }

  /// Get recent security alerts (admin only)
  Future<List<Map<String, dynamic>>> getSecurityAlerts({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('security_alerts')
          .where('acknowledged', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('[ERROR] Failed to fetch security alerts: $e');
      return [];
    }
  }

  AuditLogEntry _parseAuditLog(Map<String, dynamic> data) {
    return AuditLogEntry(
      userId: data['userId'],
      email: data['email'],
      action: AuditAction.values.firstWhere(
        (a) => a.value == data['action'],
        orElse: () => AuditAction.login,
      ),
      status: AuditStatus.values
          .firstWhere((s) => s.name == data['status']),
      reason: data['reason'],
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
      additionalData: data['additionalData'],
    );
  }
}
