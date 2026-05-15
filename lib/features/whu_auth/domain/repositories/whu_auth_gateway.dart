import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/domain/models/whu_cas_service_request.dart';

abstract class WhuServiceSession extends http.BaseClient {
  Uri? get lastResponseUri;
}

abstract class WhuAuthGateway {
  Future<WhuServiceSession> authorizeService(WhuCasServiceRequest request);

  Future<WhuServiceSession> authorizeEducation();
}
