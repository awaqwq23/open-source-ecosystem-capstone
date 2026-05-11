import 'package:http/http.dart' as http;

typedef WhuCasSuccessPredicate = bool Function(http.Response response);
typedef WhuCasFailureParser = String? Function(http.Response response);

class WhuCasServiceRequest {
  const WhuCasServiceRequest({
    required this.serviceUrl,
    required this.isSuccess,
    this.parseFailure,
  });

  final Uri serviceUrl;
  final WhuCasSuccessPredicate isSuccess;
  final WhuCasFailureParser? parseFailure;
}
