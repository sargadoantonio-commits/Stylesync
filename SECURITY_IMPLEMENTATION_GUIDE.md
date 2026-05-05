# StyleSync Security Implementation Guide

## Quick Start - Security Features

### 1. Session Timeout Setup

Add to your main app widget or root dashboard:

```dart
import 'package:stylesync/features/auth/presentation/providers/session_timeout_provider.dart';
import 'package:stylesync/features/auth/presentation/widgets/session_timeout_warning_dialog.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Your main app content
            Consumer(
              builder: (context, ref, child) {
                // Reset session timer on user interaction
                return GestureDetector(
                  onTap: () {
                    ref.read(sessionTimeoutProvider.notifier).resetInactivityTimer();
                  },
                  child: YourMainAppContent(),
                );
              },
            ),
            // Show session timeout warning
            const SessionTimeoutWarningDialog(),
          ],
        ),
      ),
    );
  }
}
```

---

### 2. Password Strength + Breach Detection in Registration

```dart
import 'package:stylesync/features/auth/presentation/widgets/password_strength_indicator.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  String _password = '';
  bool _isPasswordValid = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Password input field
        TextField(
          obscureText: true,
          onChanged: (value) {
            setState(() => _password = value);
          },
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter a strong password',
          ),
        ),
        const SizedBox(height: 16),
        
        // Password strength indicator (includes breach detection)
        PasswordStrengthIndicator(
          password: _password,
          onStrengthChanged: (isValid) {
            setState(() => _isPasswordValid = isValid);
          },
        ),
        const SizedBox(height: 16),
        
        // Register button (disabled until password is strong)
        ElevatedButton(
          onPressed: _isPasswordValid ? _handleRegister : null,
          child: const Text('Create Account'),
        ),
      ],
    );
  }

  void _handleRegister() {
    // Registration logic with audit logging
    ref.read(sessionTimeoutProvider.notifier).resetInactivityTimer();
    // ... call auth repository ...
  }
}
```

---

### 3. Audit Logging Integration

Update your auth repository to log all auth events:

```dart
import 'package:stylesync/features/auth/domain/audit_logger.dart';

class AuthRepository {
  final AuditLogger _auditLogger = AuditLogger();

  // In signInWithUsername method:
  Future<void> signInWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      // ... existing sign-in logic ...
      
      final uid = cred.user!.uid;
      
      // Log successful login
      await _auditLogger.logAuthEvent(
        userId: uid,
        email: cred.user!.email,
        action: AuditAction.login,
        status: AuditStatus.success,
        additionalData: {
          'method': 'username',
          'provider': 'password',
        },
      );
    } catch (e) {
      // Log failed login attempt
      await _auditLogger.logAuthEvent(
        email: email,
        action: AuditAction.loginFailed,
        status: AuditStatus.failure,
        reason: e.toString(),
        additionalData: {
          'method': 'username',
          'attemptCount': (await _auditLogger.getUserAuditLogs('').length),
        },
      );
      rethrow;
    }
  }

  // In register method:
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      // ... existing registration logic ...
      
      // Log successful registration
      await _auditLogger.logAuthEvent(
        userId: userRecord.user!.uid,
        email: email,
        action: AuditAction.registration,
        status: AuditStatus.success,
        additionalData: {
          'role': role.firestoreValue,
        },
      );
    } catch (e) {
      // Log failed registration
      await _auditLogger.logAuthEvent(
        email: email,
        action: AuditAction.registration,
        status: AuditStatus.failure,
        reason: e.toString(),
      );
      rethrow;
    }
  }

  // In logout/signOut method:
  Future<void> signOut() async {
    final currentUser = _auth.currentUser;
    try {
      await _auth.signOut();
      
      if (currentUser != null) {
        await _auditLogger.logAuthEvent(
          userId: currentUser.uid,
          email: currentUser.email,
          action: AuditAction.logout,
          status: AuditStatus.success,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

---

### 4. Create Admin Security Dashboard

```dart
import 'package:stylesync/features/auth/domain/audit_logger.dart';

class SecurityAuditDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogger = AuditLogger();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Audit Logs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Alerts
          FutureBuilder<List<Map<String, dynamic>>>(
            future: auditLogger.getSecurityAlerts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final alerts = snapshot.data ?? [];
              
              if (alerts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('✓ No security alerts'),
                  ),
                );
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🚨 Security Alerts (${alerts.length})'),
                  const SizedBox(height: 12),
                  ...alerts.map((alert) => AlertCard(alert: alert)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          // User Audit Logs
          Text('📋 Recent Auth Events'),
          const SizedBox(height: 12),
          FutureBuilder<List<AuditLogEntry>>(
            future: auditLogger.getUserAuditLogs(ref.read(userIdProvider) ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final logs = snapshot.data ?? [];
              
              return Column(
                children: logs
                    .map((log) => AuditLogTile(entry: log))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  
  const AlertCard({required this.alert});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: Icon(Icons.warning, color: Colors.red.shade700),
        title: Text(alert['action'] ?? 'Unknown'),
        subtitle: Text(alert['reason'] ?? 'No details'),
        trailing: const Icon(Icons.info),
      ),
    );
  }
}

class AuditLogTile extends StatelessWidget {
  final AuditLogEntry entry;
  
  const AuditLogTile({required this.entry});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          entry.status == AuditStatus.success
              ? Icons.check_circle
              : Icons.error_circle,
          color: entry.status == AuditStatus.success
              ? Colors.green
              : Colors.red,
        ),
        title: Text(entry.action.value),
        subtitle: Text(
          '${entry.email ?? entry.userId} • ${entry.timestamp}',
        ),
      ),
    );
  }
}
```

---

### 5. Environment Variables for Production

Create `.env.production` file (never commit to git):

```bash
# Firebase
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=style-sync-84923.firebaseapp.com
FIREBASE_PROJECT_ID=style-sync-84923
FIREBASE_STORAGE_BUCKET=style-sync-84923.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# Security
STYLESYNC_PEPPER=your_secret_pepper_from_firebase_secret_manager
SESSION_TIMEOUT_MINUTES=30
ENABLE_MFA=true
ENABLE_BREACH_CHECK=true
ENABLE_AUDIT_LOGGING=true
```

Add to `.gitignore`:
```
.env.production
.env.staging
.env
```

---

### 6. Cloud Functions Deployment Checklist

```bash
# 1. Ensure Blaze plan is active
firebase projects:list

# 2. Create pepper secret
printf '%s' "your_secure_pepper_here" | firebase functions:secrets:set STYLESYNC_PEPPER

# 3. Verify secret was created
firebase functions:secrets:get STYLESYNC_PEPPER

# 4. Deploy functions
firebase deploy --only functions

# 5. Monitor logs
firebase functions:log --limit=50
```

---

### 7. Security Best Practices Checklist

- [ ] **Session Timeout**: 30 minutes inactivity auto-logout
- [ ] **Password Strength**: Min 8 chars, mixed case, numbers, symbols
- [ ] **Breach Detection**: Have I Been Pwned integration
- [ ] **Audit Logging**: All auth events tracked
- [ ] **Rate Limiting**: Enforced at Firebase Auth level
- [ ] **App Check**: Enabled for all platforms (reCAPTCHA, SafetyNet, DeviceCheck)
- [ ] **Firestore Rules**: Client-proof, read/write restricted by role
- [ ] **Secrets Management**: Pepper in Firebase Secret Manager (not hardcoded)
- [ ] **HTTPS Only**: Firebase enforces TLS
- [ ] **Regular Audits**: Monthly review of security logs and alerts

---

### 8. Testing Security Features

```dart
// Test session timeout
test('Session expires after 30 minutes inactivity', () async {
  final notifier = SessionTimeoutNotifier(mockAuth);
  
  // Simulate 30 minutes
  await Future.delayed(const Duration(minutes: 30));
  
  // Should be logged out
  expect(mockAuth.currentUser, null);
});

// Test password breach detection
test('Compromised password is rejected', () async {
  final result = await PasswordBreachChecker.checkPassword('password123');
  
  expect(result.isCompromised, true);
  expect(result.timesCompromised, greaterThan(0));
});

// Test audit logging
test('Login event is logged', () async {
  await auditLogger.logAuthEvent(
    userId: 'test-uid',
    action: AuditAction.login,
    status: AuditStatus.success,
  );
  
  final logs = await auditLogger.getUserAuditLogs('test-uid');
  expect(logs.length, greaterThan(0));
});
```

---

## Production Deployment Steps

1. **Upgrade Firebase to Blaze plan** ✓
2. **Create and deploy Pepper secret** ✓
3. **Update Cloud Functions with Secret Manager** ✓
4. **Deploy Firestore security rules** ✓
5. **Add session timeout to main app** ✓
6. **Integrate password strength + breach detection** ✓
7. **Enable audit logging in auth repository** ✓
8. **Create security dashboard for admins** ✓
9. **Test all features in staging** ⏳
10. **Deploy to production** ⏳

---

## Security Monitoring

### Weekly Tasks
- Review security alerts dashboard
- Check audit logs for suspicious patterns
- Verify rate limiting is working

### Monthly Tasks
- Review failed login attempts
- Check password compromise incidents
- Audit admin actions
- Rotate pepper secret (optional but recommended)

### Quarterly Tasks
- Security audit of entire system
- Penetration testing
- Dependency vulnerability scanning
- Access control review

---

## References & Resources

- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Firebase Security Best Practices](https://firebase.google.com/docs/database/security/start)
- [Bcrypt Best Practices](https://en.wikipedia.org/wiki/Bcrypt)
- [Have I Been Pwned API](https://haveibeenpwned.com/API/v3)
- [Dart Security Packages](https://pub.dev/packages?q=security)

---

## Questions? Issues?

Contact: security@stylesync.dev
Report Security Issues: Please use responsible disclosure
