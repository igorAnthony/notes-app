import 'package:flutter_primeiro_app/services/auth/auth_exceptions.dart';
import 'package:flutter_primeiro_app/services/auth/auth_provider.dart';
import 'package:flutter_primeiro_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

class NotInitializedException implements Exception {}
void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });
    test("Cannot log out if not initialized", () {
      expect(
          provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>())); //TypeMacher é o tipo esperado
    });
    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test("Should be able to initialize in less than 2 seconds", () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test("Create user should delegate to LogIn function", () async {
      final badEmailUser = provider.createUser(
        email: "lorem@ipsum.com",
        password: "abacat",
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: "email@email.com",
        password: "123456",
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: "email",
        password: "password",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("Logged in user should be able to get verified", () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      await provider.logIn(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}


class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (email == "lorem@ipsum.com") {
      throw UserNotFoundAuthException();
    } 
    if (password == "123456") {throw WrongPasswordAuthException();}
    
    const user = AuthUser(isEmailVerified: false, email:"email", id: 'my-id');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: "email", id: 'my-id');
    _user = newUser;
  }
}
