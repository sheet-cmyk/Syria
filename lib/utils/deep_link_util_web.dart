// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? getAdDocIdFromCurrentUrl() {
  final hash = html.window.location.hash; // "#/ad/docId"
  if (hash.startsWith('#/ad/')) {
    return hash.substring(5).split('?').first.trim();
  }
  return null;
}
