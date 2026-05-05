/// Thrown for failed username/password checks so the UI can show [message] without a "Bad state:" prefix.
///
/// Auth security is server-authoritative for StyleSync.
/// Registration uses a unique salt per user, combines password + salt + pepper,
/// and stores only the username, hashed password digest, and salt.
/// The secure implementation lives in `functions/src/auth_secure.ts`.
class AuthCredentialException implements Exception {
  AuthCredentialException(this.message);
  final String message;
  @override
  String toString() => message;
}
