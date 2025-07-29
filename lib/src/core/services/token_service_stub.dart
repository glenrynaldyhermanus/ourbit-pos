class TokenServiceWeb {
  static String getCurrentUrl() {
    // Return empty string for non-web platforms
    return '';
  }

  static void replaceState(String url) {
    // No-op for non-web platforms
  }
}
