class UnknownUserFacingException implements Exception {
  final String userMessage;

  new(this.userMessage);

  @override
  String toString() {
    return "UnknownUserFacingException: $userMessage";
  }
}

class ExpectedUserFacingException implements Exception {
  final String userMessage;

  new(this.userMessage);

  @override
  String toString() {
    return "ExpectedUserFacingException: $userMessage";
  }
}
