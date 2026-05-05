import "package:flutter_test/flutter_test.dart";
import "package:stylesync/features/auth/data/auth_repository.dart";

void main() {
  group("AuthRepository input validation", () {
    test("username rules reject empty and invalid chars", () {
      expect(AuthRepository.isValidUsername(""), isFalse);
      expect(AuthRepository.isValidUsername("ab"), isFalse);
      expect(AuthRepository.isValidUsername("a b"), isFalse);
      expect(AuthRepository.isValidUsername("valid_user"), isTrue);
    });

    test("password length bounds", () {
      expect(AuthRepository.isValidPassword(""), isFalse);
      expect(AuthRepository.isValidPassword("1234567"), isFalse);
      expect(AuthRepository.isValidPassword("12345678"), isTrue);
    });

    test("normalizeUsername lowercases and trims", () {
      expect(AuthRepository.normalizeUsername("  Foo_Bar  "), "foo_bar");
    });
  });
}
