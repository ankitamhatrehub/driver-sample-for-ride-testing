import 'dart:convert';

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/driver_features/coins/models/coin_models.dart';
import 'package:rider_app/service/api_client.dart';

/// A failed coins call. [message] is the server's text when it sent one.
class CoinsApiException implements Exception {
  CoinsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// The scratch card was already claimed (HTTP 409, or the server says so).
  bool get isAlreadyClaimed =>
      statusCode == 409 || message.toLowerCase().contains('already');

  @override
  String toString() => message;
}

/// Torkk Coins APIs. The bearer token is added by [apiClient], and every call
/// is logged there (`[API] before` / `[API] after`).
class CoinsApiService {
  static const _timeout = Duration(seconds: 15);

  /// GET /coins/account
  static Future<CoinAccount> fetchAccount() async {
    final body = await _get(AppUrls.coinsAccount);
    return CoinAccount.fromJson(_map(body['data']));
  }

  /// GET /coins/ledger?type=all|earned|redeemed&limit=20
  static Future<List<CoinTransaction>> fetchLedger(String type) async {
    final body = await _get(AppUrls.coinsLedger(type));
    return [
      for (final m in _list(body['transactions'])) CoinTransaction.fromJson(m),
    ];
  }

  /// GET /driver/coins/earning-rules
  static Future<List<CoinEarningRule>> fetchEarningRules() async {
    final body = await _get(AppUrls.coinsEarningRules);
    return [for (final m in _list(body['rules'])) CoinEarningRule.fromJson(m)];
  }

  /// GET /driver/coins/milestones
  static Future<List<CoinMilestone>> fetchMilestones() async {
    final body = await _get(AppUrls.coinsMilestones);
    return [
      for (final m in _list(body['milestones'])) CoinMilestone.fromJson(m),
    ];
  }

  /// GET /driver/coins/daily-missions
  static Future<List<CoinMission>> fetchDailyMissions() async {
    final body = await _get(AppUrls.coinsDailyMissions);
    return [for (final m in _list(body['missions'])) CoinMission.fromJson(m)];
  }

  /// GET /coins/scratch-cards/available. Null when there is no card.
  static Future<ScratchCard?> fetchAvailableScratchCard() async {
    final data = _map((await _get(AppUrls.scratchCardAvailable))['data']);
    if (data['has_card'] != true || data['card'] is! Map) return null;
    return ScratchCard.fromJson(_map(data['card']));
  }

  /// POST /coins/scratch-cards/{id}/claim
  static Future<ScratchClaim> claimScratchCard(String cardId) async {
    final response = await apiClient
        .post(Uri.parse(AppUrls.scratchCardClaim(cardId)))
        .timeout(_timeout);
    final body = _decode(response);
    return ScratchClaim.fromJson(_map(body['data']));
  }

  static Future<Map<String, dynamic>> _get(String url) async {
    final response = await apiClient.get(Uri.parse(url)).timeout(_timeout);
    return _decode(response);
  }

  static Map<String, dynamic> _decode(dynamic response) {
    Map<String, dynamic> body = {};
    try {
      final decoded = json.decode(response.body as String);
      if (decoded is Map) body = Map<String, dynamic>.from(decoded);
    } catch (_) {}
    final code = response.statusCode as int;
    final ok = code >= 200 && code < 300 && body['status'] != 'error';
    if (!ok) {
      final msg = body['message'] ?? body['error'] ?? body['detail'];
      throw CoinsApiException(
        msg == null ? 'Something went wrong. Please try again.' : '$msg',
        statusCode: code,
      );
    }
    return body;
  }

  static Map<String, dynamic> _map(Object? v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static List<Map<String, dynamic>> _list(Object? v) => [
    if (v is List)
      for (final item in v)
        if (item is Map) Map<String, dynamic>.from(item),
  ];
}
