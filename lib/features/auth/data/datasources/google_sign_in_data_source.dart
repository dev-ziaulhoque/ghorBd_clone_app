import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';

/// Thrown when the user dismisses the Google account picker.
/// Mapped by the repository to a friendly, localisable failure — it is
/// never treated as a successful sign-in.
class GoogleSignInCancelledException implements Exception {
  const GoogleSignInCancelledException();
}

/// Thin wrapper around the Google Sign-In SDK so the rest of the auth
/// layer stays testable and platform-free.
abstract class GoogleSignInDataSource {
  /// Runs the Google account flow and returns the ID token to exchange
  /// with the backend (`POST /auth/google`).
  Future<String> getIdToken();
}

class GoogleSignInDataSourceImpl implements GoogleSignInDataSource {
  final GoogleSignIn _googleSignIn;

  GoogleSignInDataSourceImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email', 'profile'],
            );

  @override
  Future<String> getIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw const GoogleSignInCancelledException();
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ServerException('Google ID token was not returned');
    }
    return idToken;
  }
}
