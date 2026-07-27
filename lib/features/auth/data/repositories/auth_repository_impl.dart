import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  String? get _redirectTo {
    if (kIsWeb) return null;
    if (Platform.isAndroid || Platform.isIOS) {
      return 'io.supabase.tutorsaas://login-callback';
    }
    return null;
  }

  @override
  Future<User?> signInWithGoogle() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final googleSignIn = GoogleSignIn(
        serverClientId: '466224796344-6t32htovvg5o9lqem38npfu1og3larjp.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No se pudo obtener el ID Token de Google.';
      }

      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return response.user;
    } else {
      // Perform Google Sign In through Supabase OAuth flow
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectTo,
      );
      return _supabaseClient.auth.currentUser;
    }
  }

  @override
  Future<User?> signInWithApple() async {
    // Perform Apple Sign In through Supabase OAuth flow
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: _redirectTo,
    );
    return _supabaseClient.auth.currentUser;
  }

  @override
  Future<User?> signInAnonymously() async {
    final response = await _supabaseClient.auth.signInAnonymously();
    return response.user;
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
}
