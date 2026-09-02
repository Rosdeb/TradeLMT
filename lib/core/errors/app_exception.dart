/// Typed API error thrown by [ApiService].
///
/// Keeps the human-readable [message] (so existing `Text('$e')` call sites are
/// unchanged) plus the HTTP [statusCode] so callers such as
/// `TradeMonitorService` can branch on 401 / 404 / 429 / 5xx.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => message;
}
