import "package:cloud_firestore/cloud_firestore.dart";
import "package:cloud_functions/cloud_functions.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:google_sign_in/google_sign_in.dart";

import "../../../core/oauth_config.dart";
import "../domain/password_security_engine.dart";
import "../domain/user_model.dart";
import "../domain/user_role.dart";

/// StyleSync auth: **Firebase Auth** sessions + **Cloud Functions** for salted/peppered
/// password verification (bcrypt + Secret Manager pepper). Clients never see the pepper
/// and never perform password hashing.
class AuthRepository {
  AuthRepository(this._auth, this._firestore, [FirebaseFunctions? functions]) {
    // Store functions reference if provided
    if (functions != null) {
      // Firebase Functions instance available for future use
    }
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection("users");
  CollectionReference<Map<String, dynamic>> get _usernameIndex =>
      _firestore.collection("username_index");

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserModel?> fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Stream<UserModel?> profileStream(String uid) {
    return _users.doc(uid).snapshots().map((d) {
      if (!d.exists || d.data() == null) return null;
      return UserModel.fromMap(uid, d.data()!);
    });
  }

  static String normalizeUsername(String username) =>
      username.trim().toLowerCase();

  static bool isValidUsername(String username) {
    final u = username.trim();
    final re = RegExp(r"^[a-zA-Z0-9_]+$");
    return u.length >= 3 && u.length <= 50 && re.hasMatch(u);
  }

  static bool isValidPassword(String password) =>
      password.length >= 8 && password.length <= 100;

  /// Direct Firebase Auth signup (FREE on Spark plan - no Cloud Functions needed)
  /// Creates Auth user, checks for username duplicates, and creates Firestore profile
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    bool isPremium = false,
  }) async {
    // Client-side validation
    if (!isValidUsername(username)) {
      throw ArgumentError(
          "Username must be 3–50 chars: letters, numbers, underscore only.");
    }
    if (!isValidPassword(password)) {
      throw ArgumentError("Password must be 8–100 characters.");
    }

    try {
      final nu = normalizeUsername(username);

      // Check if username already exists (free Spark plan check)
      final indexSnap = await _usernameIndex.doc(nu).get();
      if (indexSnap.exists) {
        throw StateError(
            "❌ Username already taken. Please choose another one.");
      }

      // Create Firebase Auth user (FREE)
      final userRecord = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userRecord.user!.uid;

      // Create username index for quick lookups
      await _usernameIndex.doc(nu).set({
        "uid": uid,
        "email": email.trim().toLowerCase(),
      });

      // Check if this is the admin account
      // Admin account: sargado.antonioe@dnsc.edu.ph with barber role
      final isAdmin = email.trim().toLowerCase() == "sargado.antonioe@dnsc.edu.ph" &&
          role == UserRole.barber;

      // Create user profile document with all required fields
      await _users.doc(uid).set({
        "role": role.firestoreValue,
        "username": username.trim(),
        "displayName": username.trim(),
        "photoUrl": "",
        "email": email.trim().toLowerCase(),
        "phoneNumber": "",
        "providerIds": ["password"],
        "xp": 0,
        "loyaltyRank": "rookie",
        "isPremium": isPremium,
        "profileComplete": false,
        "hairProfile": {
          "type": "straight",
          "density": "medium",
          "scalpSensitivity": "medium",
        },
        "isAdmin": isAdmin,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "lastLoginAt": FieldValue.serverTimestamp(),
      });

      // Send email verification (optional, non-blocking)
      try {
        await userRecord.user!.sendEmailVerification();
      } catch (e) {
        debugPrint("Email verification send failed: $e");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        throw StateError(
            "❌ Email already registered. Please log in or use a different email.");
      }
      if (e.code == "invalid-email") {
        throw StateError(
            "The email address is invalid. Please check and try again.");
      }
      if (e.code == "weak-password") {
        throw StateError(
            "Password is too weak. Please use 8+ characters with mixed case.");
      }
      if (e.code == "too-many-requests") {
        throw StateError(
            "Too many signup attempts. Please wait a few minutes before trying again.");
      }
      throw StateError(
          "Account creation failed: ${e.message ?? "Unknown error"}. Please try again.");
    } catch (e) {
      // Handle Firestore errors
      if (e is StateError) {
        rethrow;
      }
      throw StateError(
          "Signup failed: ${e.toString()}. Please try again or contact support.");
    }
  }

  /// Direct Firebase Auth login using username (FREE on Spark plan)
  /// Looks up email from username, then signs in
  Future<void> signInWithUsername({
    required String username,
    required String password,
  }) async {
    const invalid = "Invalid Username or Password";
    try {
      final nu = normalizeUsername(username);

      // Look up email from username index (free Firestore read)
      final indexSnap = await _usernameIndex.doc(nu).get();
      if (!indexSnap.exists) {
        throw AuthCredentialException(invalid);
      }

      final email = indexSnap.data()?["email"] as String?;
      if (email == null || email.isEmpty) {
        throw AuthCredentialException(invalid);
      }

      // Sign in with email and password (free Firebase Auth)
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        await ensureUserDocument(cred.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found" ||
          e.code == "wrong-password" ||
          e.code == "invalid-email") {
        throw AuthCredentialException(invalid);
      }
      if (e.code == "user-disabled") {
        throw AuthCredentialException("This account has been disabled.");
      }
      if (e.code == "too-many-requests") {
        throw AuthCredentialException(
            "Too many login attempts. Try again later.");
      }
      throw AuthCredentialException(invalid);
    } on AuthCredentialException {
      rethrow;
    } catch (e) {
      throw AuthCredentialException(invalid);
    }
  }

  /// Direct Firebase Auth login using email (FREE on Spark plan)
  /// Signs in directly with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    const invalid = "Invalid Email or Password";
    try {
      final trimmedEmail = email.trim().toLowerCase();

      // Sign in with email and password (free Firebase Auth)
      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      if (cred.user != null) {
        await ensureUserDocument(cred.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found" ||
          e.code == "wrong-password" ||
          e.code == "invalid-email") {
        throw AuthCredentialException(invalid);
      }
      if (e.code == "user-disabled") {
        throw AuthCredentialException("This account has been disabled.");
      }
      if (e.code == "too-many-requests") {
        throw AuthCredentialException(
            "Too many login attempts. Try again later.");
      }
      throw AuthCredentialException(invalid);
    } on AuthCredentialException {
      rethrow;
    } catch (e) {
      throw AuthCredentialException(invalid);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetForUsername(String username) async {
    final nu = normalizeUsername(username);
    final index = await _usernameIndex.doc(nu).get();
    if (!index.exists) {
      throw StateError("Username does not exist.");
    }
    final email = index.data()?["email"] as String? ?? "";
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendPasswordResetEmail(String emailOrUsername) async {
    final input = emailOrUsername.trim().toLowerCase();
    
    try {
      // First, try to send reset email directly (if it's an email address)
      if (input.contains("@")) {
        await _auth.sendPasswordResetEmail(email: input);
        return;
      }
      
      // Otherwise, treat it as a username and look it up
      final nu = normalizeUsername(input);
      final index = await _usernameIndex.doc(nu).get();
      if (!index.exists) {
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "No account found with this username or email.",
        );
      }
      final email = index.data()?["email"] as String? ?? "";
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found" || e.code == "invalid-email") {
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "No account found with this email or username.",
        );
      }
      rethrow;
    }
  }

  Future<void> updateUsername({
    required String newUsername,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw StateError("Not signed in.");

    final nu = normalizeUsername(newUsername);
    if (!isValidUsername(newUsername)) {
      throw ArgumentError("Invalid username.");
    }

    final cred = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);

    final indexRef = _usernameIndex.doc(nu);
    final taken = await indexRef.get();
    if (taken.exists && taken.data()?["uid"] != user.uid) {
      throw StateError("Username already taken.");
    }

    final currentSnap = await _users.doc(user.uid).get();
    final currentUsername = currentSnap.data()?["username"] as String? ?? "";
    if (currentUsername.trim().isEmpty) {
      throw StateError("Current username missing.");
    }

    final oldKey = normalizeUsername(currentUsername);
    final batch = _firestore.batch();
    batch.delete(_usernameIndex.doc(oldKey));
    batch.set(indexRef, {"uid": user.uid, "email": user.email!});
    batch.update(_users.doc(user.uid), {
      "username": newUsername.trim(),
      "displayName": newUsername.trim(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isValidPassword(newPassword)) {
      throw ArgumentError("Password must be 8–100 characters.");
    }
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw StateError("Not signed in.");

    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      // Update user profile timestamp (FREE - no Cloud Functions needed)
      await _users
          .doc(user.uid)
          .update({"updatedAt": FieldValue.serverTimestamp()});
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        throw ArgumentError("Current password is incorrect.");
      }
      if (e.code == "weak-password") {
        throw ArgumentError(
            "New password is too weak. Use 8+ characters with mixed case.");
      }
      throw StateError(
          "Password change failed: ${e.message ?? "Unknown error"}. Try again.");
    }
  }

  Future<void> ensureUserDocument(User user,
      {UserRole defaultRole = UserRole.customer}) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();

    final providerIds =
        user.providerData.map((p) => p.providerId).toSet().toList();
    final displayName = (user.displayName ?? "").trim();
    final photoUrl = (user.photoURL ?? "").trim();
    final email = (user.email ?? "").trim();
    final phone = (user.phoneNumber ?? "").trim();

    // Check if this is the admin account (email match + barber role)
    final isAdmin = email.toLowerCase() == "sargado.antonioe@dnsc.edu.ph" &&
        defaultRole == UserRole.barber;

    if (!snap.exists || snap.data() == null) {
      final fallbackUsername = displayName.isNotEmpty
          ? displayName
          : (email.isNotEmpty ? email.split("@").first : "user");
      final model = UserModel(
        uid: user.uid,
        role: defaultRole,
        username: fallbackUsername,
        displayName: displayName,
        photoUrl: photoUrl,
        email: email,
        phoneNumber: phone,
        providerIds: providerIds,
        xp: 0,
        loyaltyRank: LoyaltyRank.rookie,
        isPremium: false,
        profileComplete: providerIds.contains("google.com") ? false : true,
        hairProfile: HairProfile.baseline(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isAdmin: isAdmin,
      );
      await ref.set({
        ...model.toMap(),
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "lastLoginAt": FieldValue.serverTimestamp(),
      });
      // Create username index for regular users (non-Google)
      if (!providerIds.contains("google.com") && email.isNotEmpty) {
        final normalized = normalizeUsername(fallbackUsername);
        await _usernameIndex.doc(normalized).set({
          "uid": user.uid,
          "email": email,
        });
      }
      return;
    }

    // EXISTING USER - update profile but preserve role
    final data = snap.data()!;
    final patches = <String, dynamic>{};
    if ((data["username"] as String? ?? "").isEmpty) {
      final fallbackUsername = displayName.isNotEmpty
          ? displayName
          : (email.isNotEmpty ? email.split("@").first : "");
      if (fallbackUsername.isNotEmpty) patches["username"] = fallbackUsername;
    }
    if ((data["displayName"] as String? ?? "").isEmpty &&
        displayName.isNotEmpty) {
      patches["displayName"] = displayName;
    }
    if ((data["photoUrl"] as String? ?? "").isEmpty && photoUrl.isNotEmpty) {
      patches["photoUrl"] = photoUrl;
    }
    if ((data["email"] as String? ?? "").isEmpty && email.isNotEmpty) {
      patches["email"] = email;
    }
    if ((data["phoneNumber"] as String? ?? "").isEmpty && phone.isNotEmpty) {
      patches["phoneNumber"] = phone;
    }
    patches["providerIds"] = providerIds;
    patches["lastLoginAt"] = FieldValue.serverTimestamp();
    patches["isAdmin"] = isAdmin;
    if (patches.isNotEmpty) {
      patches["updatedAt"] = FieldValue.serverTimestamp();
      await ref.update(patches);
    }
  }

  Future<void> completeProfile({
    required String username,
    required String displayName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError("No authenticated user found.");
    }
    if (!isValidUsername(username)) {
      throw ArgumentError(
          "Username must be 3–50 chars: letters, numbers, underscore only.");
    }

    final normalized = normalizeUsername(username);
    final usernameRef = _usernameIndex.doc(normalized);
    final existing = await usernameRef.get();
    if (existing.exists && existing.data()?['uid'] != user.uid) {
      throw StateError("Username already taken.");
    }

    final batch = _firestore.batch();
    batch.set(usernameRef, {"uid": user.uid, "email": user.email ?? ""});
    batch.update(_users.doc(user.uid), {
      "username": username.trim(),
      "displayName": displayName.trim(),
      "profileComplete": true,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await batch.commit();
    if (user.displayName != displayName.trim()) {
      await user.updateDisplayName(displayName.trim());
    }
  }

  Future<void> signInWithGoogle({UserRole? roleForNewAccount}) async {
    if (!OAuthConfig.isGoogleConfigured) {
      throw StateError(OAuthConfig.googleNotConfiguredError);
    }

    try {
      // Initialize Google Sign In with platform-appropriate configuration
      late final GoogleSignIn googleSignIn;

      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
      } else {
        googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
      }

      // Sign out first to ensure fresh account selection
      await googleSignIn.signOut().catchError((_) => null);

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled sign-in

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw StateError(
            "Failed to get Google authentication tokens. Please ensure Google Sign-In is properly configured in your app and try again.");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      if (cred.user == null) {
        throw StateError(
            "Google Sign-In succeeded but user creation failed. Please try again.");
      }

      // Check if existing profile has a different role (only during signup)
      final existingProfile = await fetchProfile(cred.user!.uid);
      if (existingProfile != null && roleForNewAccount != null) {
        // During signup, prevent using an email that's already associated with a different role
        if (existingProfile.role != roleForNewAccount) {
          throw StateError(
              "This Google account is already registered as a ${existingProfile.role.name}. "
              "You cannot use the same account for a different role. "
              "Please use a different Google account or sign in as a ${existingProfile.role.name}.");
        }
      }

      await ensureUserDocument(
        cred.user!,
        defaultRole: roleForNewAccount ?? UserRole.customer,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "network-request-failed" ||
          (e.message?.contains("network") ?? false)) {
        throw StateError(
            "Network error during Google Sign-In. Please check your internet connection and try again.");
      }
      if (e.code == "invalid-credential") {
        throw StateError(
            "Google Sign-In failed: Invalid credentials. Please ensure your Google OAuth is properly configured in Firebase Console.");
      }
      if (e.code == "user-disabled") {
        throw StateError(
            "This account has been disabled. Please contact support.");
      }
      if (e.code == "operation-not-allowed") {
        throw StateError(
            "Google Sign-In is not enabled in Firebase Console. Please enable it in Authentication settings.");
      }
      throw StateError("Google Sign-In failed: ${e.message ?? e.code}");
    } catch (e) {
      final text = e.toString();

      // Handle missing client ID
      if (text.contains('ClientID not set') ||
          text.contains('client_id') ||
          text.contains('Client ID')) {
        throw StateError(
            "Google Sign-In is not properly configured. Please ensure the Android OAuth client ID is set in your app configuration and try again.");
      }

      // Handle missing Google Play Services
      if (text.contains('Google Play Store') ||
          text.contains('Google Play services') ||
          text.contains('SERVICE_INVALID') ||
          text.contains('play services are missing') ||
          text.contains('Google Play services are missing') ||
          text.contains('PlatformException(Play Services')) {
        throw StateError(
            'Google Sign-In requires Google Play services on your device. Please ensure Google Play services is installed and up to date, then try again.');
      }

      // Handle missing Firebase configuration
      if (text.contains('Missing google_app_id') ||
          text.contains('google-services.json')) {
        throw StateError(
            'Firebase is missing configuration on this device. Make sure google-services.json is correctly installed in the app and the app is rebuilt.');
      }

      // Handle SHA-1 fingerprint issues
      if (text.contains('Api12500') ||
          text.contains('12500') ||
          text.contains('fingerprint')) {
        throw StateError(
            'Google Sign-In failed because the app is not configured with the correct SHA-1 fingerprint in Firebase. Please add your Android app SHA-1 to Firebase Console, update google-services.json, and rebuild the app.');
      }

      // Handle platform exceptions
      if (text.contains("PlatformException")) {
        final inner = text
            .replaceAll('PlatformException(', '')
            .replaceAll(')', '')
            .trim();
        final cleaned = inner
            .replaceAll('Bad state: ', '')
            .replaceAll('Exception: ', '')
            .trim();
        if (cleaned.isNotEmpty && !cleaned.contains('null')) {
          throw StateError(cleaned);
        }
      }

      // Handle network errors
      if (text.contains("network") || text.contains("Network")) {
        throw StateError(
            "Network error during Google Sign-In. Please check your internet connection and try again.");
      }

      // Generic error message
      final cleaned = text
          .replaceAll('Bad state: ', '')
          .replaceAll('Exception: ', '')
          .trim();
      throw StateError(cleaned.isNotEmpty
          ? "Google Sign-In failed: $cleaned"
          : 'Google Sign-In failed. Please try again.');
    }
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _users.doc(uid).update({
      "role": role.firestoreValue,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
