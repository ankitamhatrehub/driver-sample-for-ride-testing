import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/driver_features/profile/models/support_ticket.dart';
import 'package:rider_app/service/api_client.dart';

class SupportOption {
  const SupportOption({required this.id, required this.name});

  final String id;
  final String name;
}

/// Driver support-ticket endpoints (`/api/driver/support/...`).
/// Every method throws an [Exception] carrying the server message on failure.
class SupportApiService {
  static const _timeout = Duration(seconds: 15);
  static const _uploadTimeout = Duration(seconds: 60);

  /// GET /categories
  static Future<List<SupportOption>> fetchCategories() async {
    final data = await _get(AppUrls.supportCategories, 'CATEGORIES');
    return _options(data['data']);
  }

  /// GET /categories/{id}/problems
  static Future<List<SupportOption>> fetchProblems(String categoryId) async {
    final data = await _get(AppUrls.supportProblems(categoryId), 'PROBLEMS');
    return _options(data['data']);
  }

  /// GET /tickets
  static Future<List<SupportTicket>> fetchTickets({
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    final query =
        'page=$page&limit=$limit'
        '${status == null ? '' : '&status=$status'}';
    final data = await _get('${AppUrls.supportTickets}?$query', 'TICKETS');

    return [
      for (final t in (data['data'] as List? ?? const []))
        SupportTicket.fromJson(Map<String, dynamic>.from(t as Map)),
    ];
  }

  /// GET /tickets/{id}
  static Future<SupportTicket> fetchTicket(String ticketId) async {
    final data = await _get(AppUrls.supportTicket(ticketId), 'TICKET DETAIL');
    return SupportTicket.fromJson(Map<String, dynamic>.from(data['data']));
  }

  /// POST /tickets (multipart). Returns the created ticket with its
  /// `ticket_id` and `ticket_number` filled in.
  static Future<SupportTicket> createTicket({
    required String categoryId,
    required String categoryName,
    required String problemId,
    required String problemName,
    required String description,
    String quickNote = '',
    String rideId = '',
    List<String> photoPaths = const [],
  }) async {
    final fields = {
      'category_id': categoryId,
      'problem_id': problemId,
      'description': description,
      if (quickNote.isNotEmpty) 'quick_note': quickNote,
      if (rideId.isNotEmpty) 'ride_id': rideId,
    };
    final data = await _multipart(
      AppUrls.supportTickets,
      'CREATE TICKET',
      fields,
      photoPaths,
    );
    final created = Map<String, dynamic>.from(data['data'] as Map);
    final date = formatTicketDate(created['created_at']);
    return SupportTicket(
      ticketId: '${created['ticket_id'] ?? ''}',
      ticketNumber: '${created['ticket_number'] ?? ''}',
      title: problemName,
      date: date,
      status: SupportTicket.statusFromApi('${created['status'] ?? ''}'),
      rawStatus: '${created['status'] ?? ''}',
      issue: categoryName,
      category: problemName,
      description: description,
      created: date,
      updated: date,
      photos: photoPaths,
    );
  }

  /// POST /tickets/{id}/follow-up (multipart)
  static Future<void> followUp(
    String ticketId,
    String message, {
    List<String> photoPaths = const [],
  }) async {
    await _multipart(AppUrls.supportTicketFollowUp(ticketId), 'FOLLOW UP', {
      'message': message,
    }, photoPaths);
  }

  /// POST /tickets/{id}/reopen (JSON)
  static Future<void> reopen(String ticketId, String reason) async {
    final url = AppUrls.supportTicketReopen(ticketId);
    debugPrint('[SUPPORT REOPEN] BEFORE -> POST $url reason=$reason');
    final response = await apiClient
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'reason': reason}),
        )
        .timeout(_timeout);
    debugPrint(
      '[SUPPORT REOPEN] AFTER <- status=${response.statusCode} body=${response.body}',
    );
    _decode(response, 'REOPEN');
  }

  static Future<Map<String, dynamic>> _get(String url, String tag) async {
    debugPrint('[SUPPORT $tag] BEFORE -> GET $url');
    final response = await apiClient.get(Uri.parse(url)).timeout(_timeout);
    debugPrint(
      '[SUPPORT $tag] AFTER <- status=${response.statusCode} body=${response.body}',
    );
    return _decode(response, tag);
  }

  static Future<Map<String, dynamic>> _multipart(
    String url,
    String tag,
    Map<String, String> fields,
    List<String> photoPaths,
  ) async {
    debugPrint(
      '[SUPPORT $tag] BEFORE -> POST $url fields=$fields photos=$photoPaths',
    );
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields.addAll(fields);
    for (final path in photoPaths) {
      request.files.add(await http.MultipartFile.fromPath('photos', path));
    }
    final streamed = await apiClient.send(request).timeout(_uploadTimeout);
    final response = await http.Response.fromStream(streamed);
    debugPrint(
      '[SUPPORT $tag] AFTER <- status=${response.statusCode} body=${response.body}',
    );
    return _decode(response, tag);
  }

  static Map<String, dynamic> _decode(http.Response response, String tag) {
    Map<String, dynamic> body = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) body = Map<String, dynamic>.from(decoded);
    } catch (_) {}
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (ok && body['status'] != 'error') return body;
    final message = body['message'] ?? body['error'];
    throw Exception(
      message != null && '$message'.isNotEmpty
          ? '$message'
          : 'Request failed (${response.statusCode})',
    );
  }

  static List<SupportOption> _options(Object? list) => [
    for (final o in (list as List? ?? const []))
      SupportOption(id: '${(o as Map)['id']}', name: '${o['name']}'),
  ];
}
