class UserFacingException implements Exception {
  final String message;

  new(this.message);

  @override
  String toString() {
    return "ResponseException: $message";
  }
}
