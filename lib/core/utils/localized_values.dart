import 'package:flutter/widgets.dart';

class LocalizedValues {
  LocalizedValues._();

  static bool isArabicLanguageCode(String languageCode) {
    return languageCode.toLowerCase().startsWith('ar');
  }

  static String select({
    required String languageCode,
    required String ar,
    required String en,
  }) {
    final primary = isArabicLanguageCode(languageCode) ? ar : en;
    final fallback = isArabicLanguageCode(languageCode) ? en : ar;
    return primary.trim().isNotEmpty ? primary : fallback;
  }

  static String selectForContext(
    BuildContext context, {
    required String ar,
    required String en,
  }) {
    return select(
      languageCode: Localizations.localeOf(context).languageCode,
      ar: ar,
      en: en,
    );
  }
}
