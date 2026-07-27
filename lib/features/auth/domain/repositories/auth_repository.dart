import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<User?> signInAnonymously();
  Future<void> signOut();
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}
