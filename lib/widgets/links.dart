import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// Opens the user's email app with a new message to support.
/// If no email app is available, the address is copied instead.
Future<void> contactSupport(BuildContext context, {String subject = 'Dayloop support'}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final uri = Uri.parse('mailto:${AppConfig.supportEmail}?subject=${Uri.encodeComponent(subject)}');
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not open email app: $e');
  }
  if (opened) return;
  await Clipboard.setData(const ClipboardData(text: AppConfig.supportEmail));
  messenger?.showSnackBar(
    const SnackBar(content: Text('No email app found. Our address was copied: ${AppConfig.supportEmail}')),
  );
}

/// Opens a web page in the browser. Returns false if it could not be opened.
Future<bool> openWebPage(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not open $url: $e');
    return false;
  }
}
