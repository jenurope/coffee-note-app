enum InquiryType {
  general,
  bug,
  feature,
  account,
  technical;

  String get value => switch (this) {
    InquiryType.general => 'general',
    InquiryType.bug => 'bug',
    InquiryType.feature => 'feature',
    InquiryType.account => 'account',
    InquiryType.technical => 'technical',
  };

  static InquiryType fromValue(String value) {
    return switch (value) {
      'general' => InquiryType.general,
      'bug' => InquiryType.bug,
      'feature' => InquiryType.feature,
      'account' => InquiryType.account,
      'technical' => InquiryType.technical,
      _ => InquiryType.general,
    };
  }
}

enum InquiryStatus {
  pending,
  inProgress,
  resolved,
  closed;

  String get value => switch (this) {
    InquiryStatus.pending => 'pending',
    InquiryStatus.inProgress => 'in_progress',
    InquiryStatus.resolved => 'resolved',
    InquiryStatus.closed => 'closed',
  };

  static InquiryStatus fromValue(String value) {
    return switch (value) {
      'pending' => InquiryStatus.pending,
      'in_progress' => InquiryStatus.inProgress,
      'resolved' => InquiryStatus.resolved,
      'closed' => InquiryStatus.closed,
      _ => InquiryStatus.pending,
    };
  }
}

class ServiceInquiry {
  final String id;
  final String? userId;
  final InquiryType inquiryType;
  final InquiryStatus status;
  final String title;
  final String content;
  final String email;
  final bool personalInfoConsent;
  final List<String> attachments;
  final String? adminResponse;
  final String? adminUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  ServiceInquiry({
    required this.id,
    this.userId,
    required this.inquiryType,
    required this.status,
    required this.title,
    required this.content,
    required this.email,
    this.personalInfoConsent = false,
    this.attachments = const <String>[],
    this.adminResponse,
    this.adminUserId,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory ServiceInquiry.fromJson(Map<String, dynamic> json) {
    final attachments =
        (json['attachments'] as List?)
            ?.map((e) => e.toString())
            .toList(growable: false) ??
        const <String>[];

    return ServiceInquiry(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      inquiryType: InquiryType.fromValue(json['inquiry_type'] as String),
      status: InquiryStatus.fromValue(json['status'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      email: json['email'] as String,
      personalInfoConsent: json['personal_info_consent'] as bool? ?? false,
      attachments: attachments,
      adminResponse: json['admin_response'] as String?,
      adminUserId: json['admin_user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'inquiry_type': inquiryType.value,
      'status': status.value,
      'title': title,
      'content': content,
      'email': email,
      'personal_info_consent': personalInfoConsent,
      'attachments': attachments,
      'admin_response': adminResponse,
      'admin_user_id': adminUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'inquiry_type': inquiryType.value,
      'title': title,
      'content': content,
      'email': email,
      'personal_info_consent': personalInfoConsent,
    };
  }

  ServiceInquiry copyWith({
    String? id,
    String? userId,
    InquiryType? inquiryType,
    InquiryStatus? status,
    String? title,
    String? content,
    String? email,
    bool? personalInfoConsent,
    List<String>? attachments,
    String? adminResponse,
    String? adminUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return ServiceInquiry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      inquiryType: inquiryType ?? this.inquiryType,
      status: status ?? this.status,
      title: title ?? this.title,
      content: content ?? this.content,
      email: email ?? this.email,
      personalInfoConsent: personalInfoConsent ?? this.personalInfoConsent,
      attachments: attachments ?? this.attachments,
      adminResponse: adminResponse ?? this.adminResponse,
      adminUserId: adminUserId ?? this.adminUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
