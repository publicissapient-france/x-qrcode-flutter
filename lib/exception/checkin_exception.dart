class CheckInException implements Exception {
  final String message;

  CheckInException(this.message);

  @override
  String toString() {
    return message;
  }
}
