/// Google Cloud OAuth for Amanaat Drive backup (Android).
///
/// Same Cloud project as Budget Pro / Budget Web: `model-charge-510905-q4`.
///
/// Required in that project (OAuth steps after APK):
/// 1. Enable **Google Drive API** (if not already)
/// 2. OAuth consent → add your Gmail as **Test user** (while Testing)
/// 3. New OAuth client **Android**:
///    - Name e.g. "Amanaat this PC"
///    - Package name = [androidPackage]
///    - SHA-1 = [apkSha1]
/// 4. Keep existing **Web application** client → [webClientId]
class GoogleOAuthConfig {
  GoogleOAuthConfig._();

  static const String androidPackage = 'com.amanah.amanah';

  /// SHA-1 of APKs signed with this PC's debug keystore (current release signing).
  static const String apkSha1 =
      '35:CA:B2:8A:B1:A4:27:B6:C0:28:3F:04:3C:E4:14:1F:66:66:9B:A5';

  /// Web OAuth client ID — same project as Budget (serverClientId for GoogleSignIn).
  static const String webClientId =
      '723684429845-u03ai4pi869mjvpu2e8e2cjmc2rsljdn.apps.googleusercontent.com';
}
