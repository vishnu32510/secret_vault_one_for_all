import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'cache.dart';
import 'user.dart';

abstract class AuthenticationRepository {}

class FirebaseAuthenticationRepository extends AuthenticationRepository {
  FirebaseAuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _cache = cache ?? CacheClient(),
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  static const userCacheKey = '__user_cache_key__';

  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final mapped = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: mapped);
      return mapped;
    });
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(
        e.code,
        messageString: e.message,
      );
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(
        e.code,
        messageString: e.message,
      );
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      throw const LogOutFailure();
    }
  }

  Future<void> deleteAccount() async {
    final current = _firebaseAuth.currentUser;
    if (current == null) {
      throw const DeleteAccountFailure('No signed-in user found.');
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(current.uid)
          .delete();
    } catch (_) {
      // ignore if doc missing
    }
    try {
      await current.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw DeleteAccountFailure.fromCode(e.code, messageString: e.message);
    } catch (_) {
      throw const DeleteAccountFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser =>
      User(id: uid, email: email, name: displayName, photo: photoURL);
}

class SignUpWithEmailAndPasswordFailure implements Exception {
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred.',
    this.code = 'unknown',
  ]);

  factory SignUpWithEmailAndPasswordFailure.fromCode(
    String code, {
    String? messageString,
  }) {
    switch (code) {
      case 'invalid-email':
        return SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
          code,
        );
      case 'email-already-in-use':
        return SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
          code,
        );
      case 'weak-password':
        return SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
          code,
        );
      default:
        return SignUpWithEmailAndPasswordFailure(
          messageString ?? 'An unknown error occurred.',
          code,
        );
    }
  }

  final String message;
  final String code;
}

class LogInWithEmailAndPasswordFailure implements Exception {
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred.',
  ]);

  factory LogInWithEmailAndPasswordFailure.fromCode(
    String code, {
    String? messageString,
  }) {
    switch (code) {
      case 'invalid-credential':
        return const LogInWithEmailAndPasswordFailure(
          'Wrong email or password, please try again.',
        );
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'No account found with this email.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      default:
        return LogInWithEmailAndPasswordFailure(
          messageString ?? 'An unknown error occurred.',
        );
    }
  }

  final String message;
}

class LogOutFailure implements Exception {
  const LogOutFailure([this.message = 'An unknown error occurred.']);
  final String message;
}

class DeleteAccountFailure implements Exception {
  const DeleteAccountFailure([this.message = 'Could not delete account.']);

  factory DeleteAccountFailure.fromCode(String code, {String? messageString}) {
    switch (code) {
      case 'requires-recent-login':
        return const DeleteAccountFailure(
          'For security, please sign in again and retry deleting your account.',
        );
      case 'user-not-found':
        return const DeleteAccountFailure('Account was already removed.');
      default:
        return DeleteAccountFailure(
          messageString ?? 'Could not delete account.',
        );
    }
  }

  final String message;
}
