import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/service_inquiry.dart';

class ServiceInquiryService {
  final SupabaseClient _client;

  ServiceInquiryService(this._client);

  Future<ServiceInquiry> createInquiry(ServiceInquiry inquiry) async {
    try {
      final response = await _client
          .from('service_inquiries')
          .insert(inquiry.toInsertJson())
          .select()
          .single();
      return ServiceInquiry.fromJson(response);
    } catch (e) {
      debugPrint('Create service inquiry error: $e');
      rethrow;
    }
  }

  Future<List<ServiceInquiry>> getMyInquiries(String userId) async {
    try {
      final response = await _client
          .from('service_inquiries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ServiceInquiry.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      debugPrint('Get service inquiries error: $e');
      rethrow;
    }
  }
}
