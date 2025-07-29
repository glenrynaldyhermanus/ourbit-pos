// ignore: deprecated_member_use
import 'dart:html' as html;

class TokenServiceWeb {
  static String getCurrentUrl() {
    return html.window.location.href;
  }

  static void replaceState(String url) {
    html.window.history.replaceState({}, '', url);
  }
}
