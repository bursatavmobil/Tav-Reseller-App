// lib/features/dashboard/models/negosiasi_chat_response_model.dart

class NegosiasiChatResponseModel {
  final bool status;
  final String code;
  final String text;
  final String method;
  final List<NegotiationChatItem> data;

  NegosiasiChatResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.method,
    required this.data,
  });

  factory NegosiasiChatResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<NegotiationChatItem> dataList = list != null
        ? list.map((i) => NegotiationChatItem.fromJson(i)).toList()
        : [];

    return NegosiasiChatResponseModel(
      status: json['status'] ?? false,
      code: json['code']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      data: dataList,
    );
  }
}

class NegotiationChatItem {
  final int id;
  final int negotiationId;
  final int userIdPengirim;
  final String waktu;
  final String? pesan;
  final int? nominal;
  final bool? isApprove;
  final String? approvalBy;
  final String typeUser;
  final String? approvalName;
  final String pengirimName;
  final String? pengirimFoto;
  final List<LogNegotiationChat> logNegotiationChat;

  NegotiationChatItem({
    required this.id,
    required this.negotiationId,
    required this.userIdPengirim,
    required this.waktu,
    this.pesan,
    this.nominal,
    this.isApprove,
    this.approvalBy,
    required this.typeUser,
    this.approvalName,
    required this.pengirimName,
    this.pengirimFoto,
    required this.logNegotiationChat,
  });

  factory NegotiationChatItem.fromJson(Map<String, dynamic> json) {
    var logList = json['log_negotiation_chat'] as List?;
    List<LogNegotiationChat> logs = logList != null
        ? logList.map((i) => LogNegotiationChat.fromJson(i)).toList()
        : [];

    // PROTEKSI AMAN: Jika field mengembalikan Map/Object dari API, kita amankan agar tidak crash
    String? safeParseString(dynamic value) {
      if (value == null) return null;
      if (value is Map || value is List)
        return null; // Abaikan jika berupa Object relasi database
      return value.toString();
    }

    return NegotiationChatItem(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      negotiationId: json['negotiation_id'] is int
          ? json['negotiation_id']
          : (int.tryParse(json['negotiation_id']?.toString() ?? '') ?? 0),
      userIdPengirim: json['user_id_pengirim'] is int
          ? json['user_id_pengirim']
          : (int.tryParse(json['user_id_pengirim']?.toString() ?? '') ?? 0),
      waktu: json['waktu']?.toString() ?? '',
      pesan: safeParseString(json['pesan']),
      nominal: json['nominal'] is int
          ? json['nominal']
          : (int.tryParse(json['nominal']?.toString() ?? '') ?? null),
      isApprove: json['is_approve'] is bool
          ? json['is_approve']
          : (json['is_approve']?.toString() == '1' ||
                json['is_approve']?.toString() == 'true'),
      approvalBy: safeParseString(json['approval_by']),
      typeUser: json['type_user']?.toString() ?? '',
      approvalName: safeParseString(json['approval_name']),
      pengirimName: json['pengirim_name']?.toString() ?? '',
      pengirimFoto: safeParseString(json['pengirim_foto']),
      logNegotiationChat: logs,
    );
  }
}

class LogNegotiationChat {
  final int id;
  final int negotiationChatId;
  final int userId;
  final String typeUser;
  final bool isRead;
  final String name;

  LogNegotiationChat({
    required this.id,
    required this.negotiationChatId,
    required this.userId,
    required this.typeUser,
    required this.isRead,
    required this.name,
  });

  factory LogNegotiationChat.fromJson(Map<String, dynamic> json) {
    return LogNegotiationChat(
      id: json['id'] is int
          ? json['id']
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      negotiationChatId: json['negotiation_chat_id'] is int
          ? json['negotiation_chat_id']
          : (int.tryParse(json['negotiation_chat_id']?.toString() ?? '') ?? 0),
      userId: json['user_id'] is int
          ? json['user_id']
          : (int.tryParse(json['user_id']?.toString() ?? '') ?? 0),
      typeUser: json['type_user']?.toString() ?? '',
      isRead: json['is_read'] is bool
          ? json['is_read']
          : (json['is_read']?.toString() == '1' ||
                json['is_read']?.toString() == 'true'),
      name: json['name']?.toString() ?? '',
    );
  }
}
