import "package:cloud_firestore/cloud_firestore.dart";
import "package:cloud_functions/cloud_functions.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/auth_repository.dart";
import "../../domain/user_model.dart";

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
    ref.watch(firebaseFunctionsProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final profileByUidProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  return ref.watch(authRepositoryProvider).profileStream(uid);
});

final userProfileProvider = Provider<AsyncValue<UserModel?>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) return const AsyncData<UserModel?>(null);
      return ref.watch(profileByUidProvider(user.uid));
    },
    loading: () => const AsyncLoading<UserModel?>(),
    error: (e, st) => AsyncError<UserModel?>(e, st),
  );
});
