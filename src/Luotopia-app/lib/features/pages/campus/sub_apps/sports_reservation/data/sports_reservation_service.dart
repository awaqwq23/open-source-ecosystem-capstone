import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_api_response.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_session.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_web_session.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';

class SportsReservationService {
  SportsReservationService({required this.session, http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final SportsReservationSession session;
  final http.Client _client;
  final bool _ownsClient;

  static const _host = 'gym.whu.edu.cn';

  Future<List<SportsProject>> fetchSportsTypes({int size = 7}) async {
    final payload = await _get(
      '/api/GSSportsType/GetList',
      action: '获取运动项目列表',
      queryParameters: {'Version': '1', 'size': '$size'},
    );
    return SportsReservationJson.asMapList(
      payload,
    ).map(_parseProject).toList(growable: false);
  }

  Future<List<SportsVenue>> fetchOftenVenues() async {
    final payload = await _get(
      '/api/GSStadiums/GetOftenList',
      action: '获取常用场馆',
      queryParameters: const {'Version': '2'},
    );
    return SportsReservationJson.asMapList(
      payload,
    ).map(_parseVenue).toList(growable: false);
  }

  Future<List<SportsVenue>> fetchVenues({String keyword = ''}) async {
    final payload = await _get(
      '/api/GSStadiums/GetList2',
      action: '获取场馆列表',
      queryParameters: {'Version': '1', 'Title': keyword},
    );
    return SportsReservationJson.asMapList(
      payload,
    ).map(_parseVenue).toList(growable: false);
  }

  Future<SportsVenue> fetchVenueDetail(int venueId) async {
    final payload = await _get(
      '/api/GSStadiums/GetDetail',
      action: '获取场馆详情',
      queryParameters: {'Version': '1', 'Id': '$venueId'},
    );
    final data = SportsReservationJson.asMap(payload);
    if (data.isEmpty) {
      throw const SportsReservationApiException('获取场馆详情失败：响应为空。');
    }
    return _parseVenue(data);
  }

  Future<List<SportsProject>> fetchVenueSportsTypes(int venueId) async {
    final payload = await _get(
      '/api/GSStadiums/GetSportsTypeList',
      action: '获取场馆支持项目',
      queryParameters: {'Version': '2', 'StadiumsId': '$venueId'},
    );
    return SportsReservationJson.asMapList(
      payload,
    ).map(_parseProject).toList(growable: false);
  }

  Future<SportsAppointmentListResult> fetchAppointmentList(
    SportsReservationQuery query,
  ) async {
    final queryParameters = {
      'Version': '2',
      'SportsTypeId': '${query.sportsTypeId}',
      'AppointmentDate': _formatDate(query.appointmentDate),
      if (query.venueId != null) 'StadiumsId': '${query.venueId}',
    };
    final payload = await _get(
      '/api/GSStadiums/GetAppointmentList',
      action: '获取可预约场馆',
      queryParameters: queryParameters,
    );
    final data = SportsReservationJson.asMap(payload);
    final advanceDayCount = SportsReservationJson.readInt(
      data,
      'AdvanceAppointmentDayCount',
    );
    final advanceStartTime = SportsReservationJson.readString(
      data,
      'AdvanceAppointmentStartTime',
    );
    final items = SportsReservationJson.asMapList(data['data'])
        .map(
          (item) => _parseVenueAvailability(
            item,
            advanceAppointmentDayCount: advanceDayCount,
            advanceAppointmentStartTime: advanceStartTime,
          ),
        )
        .toList(growable: false);
    return SportsAppointmentListResult(
      advanceAppointmentDayCount: advanceDayCount,
      advanceAppointmentStartTime: advanceStartTime,
      items: items,
    );
  }

  Future<List<SportsAreaAvailability>> fetchAppointmentAreaList({
    required int stadiumsAreaId,
    required DateTime appointmentDate,
  }) async {
    final payload = await _get(
      '/api/GSStadiums/GetAppointmentAreaList',
      action: '获取可预约具体场地',
      queryParameters: {
        'Version': '2',
        'StadiumsAreaId': '$stadiumsAreaId',
        'AppointmentDate': _formatDate(appointmentDate),
      },
    );
    return SportsReservationJson.asMapList(
      payload,
    ).map(_parseAreaAvailability).toList(growable: false);
  }

  Future<String> fetchAppointmentRules() async {
    final payload = await _get(
      '/api/GSConfig/GetAppointmentRules',
      action: '获取预约规则',
      queryParameters: const {'Version': '1'},
    );
    if (payload == null) {
      return '';
    }
    if (payload is String) {
      return payload.trim();
    }
    final data = SportsReservationJson.asMap(payload);
    return SportsReservationJson.readString(data, 'Content').isNotEmpty
        ? SportsReservationJson.readString(data, 'Content')
        : SportsReservationJson.readString(data, 'Rules');
  }

  Future<List<SportsReservation>> fetchRecentlyStartReservations() async {
    final payload = await _get(
      '/api/GSOrder/GetRecentlyStartList',
      action: '获取最近开始预约',
      queryParameters: const {'Version': '1'},
    );
    return SportsReservationJson.asMapList(payload)
        .map(_parseReservation)
        .whereType<SportsReservation>()
        .toList(growable: false);
  }

  Future<SportsReservationOrderListResult> fetchOrderList({
    String sportsTypeTitle = '',
    String status = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    final payload = await _get(
      '/api/GSOrder/GetList',
      action: '获取运动场馆订单列表',
      queryParameters: {
        'Version': '1',
        'SportsTypeTitle': sportsTypeTitle,
        'Status': status,
        'Page': '$page',
        'PageSize': '$pageSize',
      },
    );
    final data = SportsReservationJson.asMap(payload);
    final items = SportsReservationJson.asMapList(data['data'] ?? payload)
        .map(_parseReservation)
        .whereType<SportsReservation>()
        .toList(growable: false);
    return SportsReservationOrderListResult(
      items: items,
      page: SportsReservationJson.readInt(data, 'page', fallback: page),
      pageCount: SportsReservationJson.readInt(data, 'pageCount', fallback: 1),
      totalCount: SportsReservationJson.readInt(data, 'dataCount'),
      pageSize: SportsReservationJson.readInt(
        data,
        'PageSize',
        fallback: pageSize,
      ),
    );
  }

  Future<SportsReservation> fetchOrderDetail(String orderNo) async {
    final payload = await _get(
      '/api/GSOrder/GetDetail',
      action: '获取运动场馆订单详情',
      queryParameters: {'Version': '1', 'OrderNo': orderNo},
    );
    final data = SportsReservationJson.asMap(payload);
    final reservation = _parseReservation(data);
    if (reservation == null) {
      throw const SportsReservationApiException('获取运动场馆订单详情失败：响应为空。');
    }
    return reservation;
  }

  Future<void> cancelOrder(String orderNo, {String remark = '操作取消'}) async {
    await _post(
      '/api/GSOrder/CancelOrder',
      action: '取消运动场馆订单',
      body: {'version': 1, 'orderNo': orderNo, 'remark': remark},
    );
  }

  Future<void> applyRefund(String orderNo, {String remark = '操作取消'}) async {
    await _post(
      '/api/GSOrder/ApplyRefund',
      action: '申请运动场馆订单退款',
      body: {'version': 1, 'orderNo': orderNo, 'remark': remark},
    );
  }

  Future<void> deleteOrder(String orderNo) async {
    await _delete(
      '/api/GSOrder/DeleteOrder',
      action: '删除运动场馆订单记录',
      body: {'version': 1, 'orderNo': orderNo},
    );
  }

  Future<SportsBlacklistStatus> checkBlacklist() async {
    final payload = await _get('/api/GSUser/CheckBackList', action: '检查预约限制状态');
    final data = SportsReservationJson.asMap(payload);
    if (payload is bool) {
      return SportsBlacklistStatus(isRestricted: payload);
    }
    return SportsBlacklistStatus(
      isRestricted:
          SportsReservationJson.readBool(data, 'IsBackList') ||
          SportsReservationJson.readBool(data, 'IsBlackList') ||
          SportsReservationJson.readBool(data, 'isRestricted'),
      message: SportsReservationJson.readString(data, 'Msg').isNotEmpty
          ? SportsReservationJson.readString(data, 'Msg')
          : SportsReservationJson.readString(data, 'Message'),
    );
  }

  Future<SportsBulletinListResult> fetchBulletins({
    int page = 1,
    int pageSize = 10,
  }) async {
    final payload = await _get(
      '/api/GSBulletins/GetList',
      action: '获取场馆公告',
      queryParameters: {
        'Version': '1',
        'Page': '$page',
        'PageSize': '$pageSize',
      },
    );
    final data = SportsReservationJson.asMap(payload);
    final source = data.isEmpty ? payload : data['data'] ?? data['items'];
    final items = SportsReservationJson.asMapList(
      source,
    ).map(_parseBulletin).whereType<SportsBulletin>().toList(growable: false);
    final totalCount = SportsReservationJson.readInt(data, 'TotalCount');
    final fallbackTotalCount = SportsReservationJson.readInt(
      data,
      'total',
      fallback: SportsReservationJson.readInt(data, 'Count'),
    );
    return SportsBulletinListResult(
      items: items,
      totalCount: totalCount == 0 ? fallbackTotalCount : totalCount,
      unreadCount: SportsReservationJson.readInt(data, 'UnreadCount'),
    );
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<Object?> _get(
    String path, {
    required String action,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(_host, path, queryParameters);
    try {
      final response = await _client.get(uri, headers: _headers);
      return SportsReservationApiResponse.decode(response, action: action);
    } on SportsReservationApiException {
      rethrow;
    } catch (error) {
      throw SportsReservationApiException('$action失败：网络请求异常。', cause: error);
    }
  }

  Future<Object?> _post(
    String path, {
    required String action,
    required Map<String, Object?> body,
  }) async {
    final uri = Uri.https(_host, path);
    try {
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      return SportsReservationApiResponse.decode(response, action: action);
    } on SportsReservationApiException {
      rethrow;
    } catch (error) {
      throw SportsReservationApiException('$action失败：网络请求异常。', cause: error);
    }
  }

  Future<Object?> _delete(
    String path, {
    required String action,
    required Map<String, Object?> body,
  }) async {
    final uri = Uri.https(_host, path);
    try {
      final request = http.Request('DELETE', uri)
        ..headers.addAll(_headers)
        ..body = jsonEncode(body);
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      return SportsReservationApiResponse.decode(response, action: action);
    } on SportsReservationApiException {
      rethrow;
    } catch (error) {
      throw SportsReservationApiException('$action失败：网络请求异常。', cause: error);
    }
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json, text/plain, */*',
    'Authorization': 'Bearer ${session.jwt}',
    'Content-Type': 'application/json',
    if (session.cookieHeader.isNotEmpty) 'Cookie': session.cookieHeader,
    'Referer': session.referer.toString(),
    'User-Agent': SportsReservationWebSession.userAgent,
  };

  SportsProject _parseProject(Map<String, Object?> item) {
    return SportsProject(
      id: SportsReservationJson.readInt(item, 'Id'),
      title: SportsReservationJson.readString(item, 'Title'),
      imageUrl: SportsReservationJson.readString(item, 'ImageUrl'),
      areaType: SportsReservationJson.readInt(item, 'AreaType'),
      sort: SportsReservationJson.readInt(item, 'Sort'),
    );
  }

  SportsVenue _parseVenue(Map<String, Object?> item) {
    final imageValues = item['Images'];
    return SportsVenue(
      id: SportsReservationJson.readInt(item, 'Id'),
      title: SportsReservationJson.readString(item, 'Title'),
      imageUrl: SportsReservationJson.readString(item, 'ImageUrl'),
      address: SportsReservationJson.readString(item, 'Address'),
      campusTitle: SportsReservationJson.readString(item, 'CampusTitle'),
      status: SportsReservationJson.readInt(item, 'Status'),
      sort: SportsReservationJson.readInt(item, 'Sort'),
      detail: SportsReservationJson.readString(item, 'Content'),
      images: imageValues is List
          ? imageValues.map((value) => '$value').toList(growable: false)
          : const [],
      supportedProjects: SportsReservationJson.asMapList(
        item['SportsTypes'],
      ).map(_parseProject).toList(growable: false),
    );
  }

  SportsVenueAvailability _parseVenueAvailability(
    Map<String, Object?> item, {
    required int advanceAppointmentDayCount,
    required String advanceAppointmentStartTime,
  }) {
    return SportsVenueAvailability(
      venue: _parseVenue(item),
      sportsTypeTitle: SportsReservationJson.readString(
        item,
        'SportsTypeTitle',
      ),
      stadiumsAreaId: SportsReservationJson.readInt(item, 'StadiumsAreaId'),
      status: SportsReservationJson.readInt(item, 'Status'),
      chargeRange: _parseChargeRange(item['SportsTypeChargeRange']),
      windows: SportsReservationJson.asMapList(
        item['AppointmentTimes'],
      ).map(_parseAppointmentWindow).toList(growable: false),
      advanceAppointmentDayCount: advanceAppointmentDayCount,
      advanceAppointmentStartTime: advanceAppointmentStartTime,
    );
  }

  SportsChargeRange _parseChargeRange(Object? value) {
    final data = SportsReservationJson.asMap(value);
    return SportsChargeRange(
      lowPrice: SportsReservationJson.readDouble(data, 'LowPrice'),
      highPrice: SportsReservationJson.readDouble(data, 'HighPrice'),
    );
  }

  SportsAreaAvailability _parseAreaAvailability(Map<String, Object?> item) {
    return SportsAreaAvailability(
      id: SportsReservationJson.readInt(item, 'Id'),
      stadiumsAreaId: SportsReservationJson.readInt(item, 'StadiumsAreaId'),
      areaNo: SportsReservationJson.readInt(item, 'AreaNo'),
      capacity: SportsReservationJson.readNullableInt(item, 'Capacity'),
      status: SportsReservationJson.readInt(item, 'Status'),
      windows: SportsReservationJson.asMapList(
        item['AppointmentTimes'],
      ).map(_parseAppointmentWindow).toList(growable: false),
    );
  }

  SportsAppointmentWindow _parseAppointmentWindow(Map<String, Object?> item) {
    return SportsAppointmentWindow(
      title: SportsReservationJson.readString(item, 'Title'),
      startTime: SportsReservationJson.readString(item, 'StartTime'),
      endTime: SportsReservationJson.readString(item, 'EndTime'),
      canReserve: SportsReservationJson.readBool(item, 'IsCanAppointment'),
      durationMinutes: SportsReservationJson.readInt(item, 'Duration'),
    );
  }

  SportsReservation? _parseReservation(Map<String, Object?> item) {
    final appointmentStartTime = SportsReservationJson.readDateTime(
      item,
      'AppointmentStartTime',
    );
    final appointmentEndTime = SportsReservationJson.readDateTime(
      item,
      'AppointmentEndTime',
    );
    final appointmentDate =
        SportsReservationJson.readDateTime(item, 'AppointmentDate') ??
        SportsReservationJson.readDateTime(item, 'UseDate') ??
        SportsReservationJson.readDateTime(item, 'Date') ??
        appointmentStartTime;
    if (appointmentDate == null) {
      return null;
    }
    final statusText = SportsReservationJson.readString(
      item,
      'StatusText',
    ).ifEmpty(SportsReservationJson.readString(item, 'StatusDesc'));
    return SportsReservation(
      id: _reservationId(item),
      venueId: SportsReservationJson.readNullableInt(item, 'StadiumsId'),
      stadiumsAreaId: SportsReservationJson.readNullableInt(
        item,
        'StadiumsAreaId',
      ),
      areaNo:
          SportsReservationJson.readNullableInt(item, 'AreaNo') ??
          SportsReservationJson.readNullableInt(item, 'StadiumsAreaConfigNo'),
      venueTitle:
          SportsReservationJson.readString(item, 'StadiumsTitle').isNotEmpty
          ? SportsReservationJson.readString(item, 'StadiumsTitle')
          : SportsReservationJson.readString(item, 'VenueTitle').ifEmpty(
              SportsReservationJson.readString(
                SportsReservationJson.asMap(item['Stadiums']),
                'Title',
              ),
            ),
      sportsTypeTitle: SportsReservationJson.readString(
        item,
        'SportsTypeTitle',
      ),
      appointmentDate: appointmentDate,
      startTime: SportsReservationJson.readString(
        item,
        'StartTime',
      ).ifEmpty(_formatTime(appointmentStartTime)),
      endTime: SportsReservationJson.readString(
        item,
        'EndTime',
      ).ifEmpty(_formatTime(appointmentEndTime)),
      status: _parseReservationStatus(item, statusText),
      paymentStatus: _parsePaymentStatus(item),
      createdAt: SportsReservationJson.readDateTime(item, 'CreateTime'),
      paymentStartTime: SportsReservationJson.readDateTime(
        item,
        'PaymentStartTime',
      ),
      paymentDeadlineTime: SportsReservationJson.readDateTime(
        item,
        'PaymentDeadlineTime',
      ),
      paymentTime: SportsReservationJson.readDateTime(item, 'PaymentTime'),
      refundDeadlineTime: SportsReservationJson.readDateTime(
        item,
        'RefundDeadlineTime',
      ),
      cancelTime: SportsReservationJson.readDateTime(item, 'CancelTime'),
      refundTime: SportsReservationJson.readDateTime(item, 'RefundTime'),
      amount:
          _nullableAmount(item, 'Amount') ??
          _nullableAmount(item, 'RealAmount'),
      totalAmount: _nullableAmount(item, 'TotalAmount'),
      discountAmount: _nullableAmount(item, 'DiscountAmount'),
      refundAmount: _nullableAmount(item, 'RefundAmount'),
      realName: SportsReservationJson.readString(item, 'RealName'),
      studentWorkNo: SportsReservationJson.readString(item, 'StudentWorkNo'),
      cancelRemark: SportsReservationJson.readString(item, 'CancelRemark'),
      rawStatus: statusText,
    );
  }

  String _reservationId(Map<String, Object?> item) {
    for (final key in const ['OrderNo', 'OrderId', 'Id']) {
      final value = SportsReservationJson.readString(item, key);
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  double? _nullableAmount(Map<String, Object?> item, String key) {
    final value = item[key];
    if (value == null) {
      return null;
    }
    final amount = SportsReservationJson.readDouble(item, key);
    return amount == 0 ? null : amount;
  }

  SportsReservationStatus _parseReservationStatus(
    Map<String, Object?> item,
    String statusText,
  ) {
    final status = SportsReservationJson.readInt(item, 'Status', fallback: -1);
    final refundStatus = SportsReservationJson.readInt(item, 'RefundStatus');
    if (status == 50 || refundStatus == 30 || statusText.contains('退款')) {
      return SportsReservationStatus.refunded;
    }
    if (statusText.contains('取消')) {
      return SportsReservationStatus.cancelled;
    }
    if (statusText.contains('完成')) {
      return SportsReservationStatus.completed;
    }
    return switch (status) {
      0 || 10 => SportsReservationStatus.pendingPayment,
      1 || 20 => SportsReservationStatus.reserved,
      2 || 40 => SportsReservationStatus.cancelled,
      3 || 30 => SportsReservationStatus.completed,
      _ => SportsReservationStatus.unknown,
    };
  }

  SportsReservationPaymentStatus _parsePaymentStatus(
    Map<String, Object?> item,
  ) {
    final reservationStatus = SportsReservationJson.readInt(
      item,
      'Status',
      fallback: -1,
    );
    final refundStatus = SportsReservationJson.readInt(item, 'RefundStatus');
    if (reservationStatus == 50 || refundStatus == 30) {
      return SportsReservationPaymentStatus.refunded;
    }
    if (SportsReservationJson.readDateTime(item, 'PaymentTime') != null) {
      return SportsReservationPaymentStatus.paid;
    }
    if (reservationStatus == 10) {
      return SportsReservationPaymentStatus.unpaid;
    }
    final status = SportsReservationJson.readInt(
      item,
      'PayStatus',
      fallback: -1,
    );
    return switch (status) {
      0 => SportsReservationPaymentStatus.unpaid,
      1 => SportsReservationPaymentStatus.paid,
      2 => SportsReservationPaymentStatus.refunded,
      _ => SportsReservationPaymentStatus.unknown,
    };
  }

  SportsBulletin? _parseBulletin(Map<String, Object?> item) {
    final title = SportsReservationJson.readString(item, 'Title');
    if (title.isEmpty) {
      return null;
    }
    return SportsBulletin(
      id: SportsReservationJson.readInt(item, 'Id'),
      title: title,
      content: SportsReservationJson.readString(item, 'Content'),
      publishedAt:
          SportsReservationJson.readDateTime(item, 'CreateTime') ??
          SportsReservationJson.readDateTime(item, 'PublishTime'),
      isRead: SportsReservationJson.readBool(item, 'IsRead'),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

extension _SportsReservationStringFallback on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
