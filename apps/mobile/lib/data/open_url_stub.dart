import 'package:url_launcher/url_launcher.dart';

// Native: open the presigned URL in the device browser.
void openUrl(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
