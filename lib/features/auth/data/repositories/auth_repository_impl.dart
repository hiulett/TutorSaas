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
    // Issue #50: el producto es Android únicamente.
    if (Platform.isAndroid) {
      return 'io.supabase.tutorsaas://login-callback';
    }
    return null;
  }

  @override
  Future<User?> signInWithGoogle() async {
    if (!kIsWeb && Platform.isAndroid) {
      final googleSignIn = GoogleSignIn(
        serverClientId: '879543775149-f9fqcrpbgq9qbk16i2rkbi78spo9jceo.apps.googleusercontent.com',
      );
      // Timeouts: si Google/Supabase no responde, se lanza y el UI lo captura
      // (snackbar) en vez de dejar el spinner bloqueado para siempre.
      final googleUser = await googleSignIn.signIn().timeout(const Duration(seconds: 25));
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication.timeout(const Duration(seconds: 15));
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No se pudo obtener el ID Token de Google.';
      }

      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      ).timeout(const Duration(seconds: 15));
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
  Future<User?> signInAnonymously() async {
    final response = await _supabaseClient.auth.signInAnonymously();
    return response.user;
  }

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final response = await _supabaseClient.auth
        .signInWithPassword(email: email, password: password)
        .timeout(const Duration(seconds: 15));
    return response.user;
  }

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    final response = await _supabaseClient.auth
        .signUp(email: email, password: password)
        .timeout(const Duration(seconds: 15));
    return response.user;
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    await _supabaseClient.auth
        .resend(type: OtpType.signup, email: email)
        .timeout(const Duration(seconds: 15));
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabaseClient.auth
        .resetPasswordForEmail(email)
        .timeout(const Duration(seconds: 15));
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
