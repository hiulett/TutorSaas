import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<User?> signInAnonymously();
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}
