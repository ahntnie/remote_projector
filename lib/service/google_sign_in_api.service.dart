import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:remote_projector_2024/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.router.dart';

class GoogleSignInService {
  static final _navigationService = appLocator<NavigationService>();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS
        ? '551379171312-n69s3j0k85l3he8vljaumhj8mfchdasm.apps.googleusercontent.com'
        : null,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );
  static Timer? _timer;

  static Future<GoogleSignInAccount?> login() async {
    try {
      return await _googleSignIn.signIn();
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (_) {}

    return null;
  }

  static Stream<GoogleSignInAccount?> get currentUserStream =>
      _googleSignIn.onCurrentUserChanged;

  static Future<bool> verifyAccessToken(String token) async {
    final response = await get(Uri.parse(
        'https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=$token'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['audience'] != null;
    }
    return false;
  }

  static void initialize() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account == null) {
        _timer?.cancel();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      if (user != null) {
        var auth = await user.authentication;
        var accessToken = auth.accessToken;

        if (accessToken != null) {
          bool isValid = await verifyAccessToken(accessToken);
          if (!isValid) {
            await logout();
            _navigationService.navigateToStartPage();
          }
        }
      }
    });
  }

  static void dispose() {
    _timer?.cancel();
  }
}
