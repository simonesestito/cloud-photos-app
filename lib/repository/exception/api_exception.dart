class APIException {
  static const kNetworkError = 1000;

  final int statusCode;

  const APIException({required this.statusCode});
}
