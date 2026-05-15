import 'package:http/http.dart' as http;

typedef WhuCasSuccessPredicate = bool Function(http.Response response);
typedef WhuCasFailureParser = String? Function(http.Response response);

class WhuCasServiceRequest {
  const WhuCasServiceRequest({
    required this.serviceUrl,
    required this.isSuccess,
    this.entryUrl,
    this.parseFailure,
  });

  final Uri serviceUrl;
  final Uri? entryUrl;
  final WhuCasSuccessPredicate isSuccess;
  final WhuCasFailureParser? parseFailure;
}
