import 'package:url_launcher/url_launcher.dart';

abstract class UrlLauncherService {
  Future<bool> openUrl(String urlString);
  Future<bool> makePhoneCall(String phoneNumber);
  Future<bool> sendEmail(String email, {String subject = '', String body = ''});
  Future<bool> openMapCoordinates(double latitude, double longitude);
}

class UrlLauncherServiceImpl implements UrlLauncherService {
  @override
  Future<bool> openUrl(String urlString) async {
    try {
      if (!urlString.startsWith('http://') &&
          !urlString.startsWith('https://')) {
        urlString = 'https://$urlString';
      }
      final uri = Uri.parse(urlString);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final clean = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri.parse('tel:$clean');
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sendEmail(
    String email, {
    String subject = '',
    String body = '',
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject.isNotEmpty) 'subject': subject,
          if (body.isNotEmpty) 'body': body,
        },
      );
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openMapCoordinates(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
