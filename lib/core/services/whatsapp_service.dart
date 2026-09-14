import 'package:url_launcher/url_launcher.dart';
import '../errors/error_messages.dart';
import '../errors/exceptions.dart';

abstract class WhatsAppService {
  Future<bool> sendOrder({
    required String phoneNumber,
    required String message,
  });
}

class WhatsAppServiceImpl implements WhatsAppService {
  @override
  Future<bool> sendOrder({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number: remove +, spaces, dashes, parentheses
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      // If starts with 00, replace with without 00
      if (cleanPhone.startsWith('00')) {
        cleanPhone = cleanPhone.substring(2);
      }

      final encodedMessage = Uri.encodeComponent(message);
      final url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

      final canOpen = await canLaunchUrl(url);
      if (canOpen) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback try launch anyway as web wa.me works
        return await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      throw WhatsAppException(
        ErrorMessages.withDetails(AppErrorKey.whatsappOpen, e),
      );
    }
  }
}
