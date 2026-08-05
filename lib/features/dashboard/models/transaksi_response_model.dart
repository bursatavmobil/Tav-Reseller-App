class TransaksiResponseModel {
  final bool status;
  final String code;
  final String text;
  final String method;

  const TransaksiResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.method,
  });

  factory TransaksiResponseModel.fromJson(Map<String, dynamic> json) {
    return TransaksiResponseModel(
      status: json['status'] ?? false,
      code: json['code']?.toString() ?? '',
      text: json['text'] ?? '',
      method: json['method'] ?? '',
    );
  }
}

class AgenTransaksiModel {
  final int id;
  final String noTransaksi;
  final int agenId;
  final int negotiationId;
  final int userId;
  final num nominal;
  final String status;
  final int countSent;
  final String? pgPaymentLink;

  const AgenTransaksiModel({
    required this.id,
    required this.noTransaksi,
    required this.agenId,
    required this.negotiationId,
    required this.userId,
    required this.nominal,
    required this.status,
    required this.countSent,
    this.pgPaymentLink,
  });

  factory AgenTransaksiModel.fromJson(Map<String, dynamic> json) {
    return AgenTransaksiModel(
      id: json['id'] ?? 0,
      noTransaksi: json['no_transaksi'] ?? '',
      agenId: json['agen_id'] ?? 0,
      negotiationId: json['negotiation_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nominal: json['nominal'] ?? 0,
      status: json['status'] ?? '',
      countSent: json['count_sent'] ?? 0,
      pgPaymentLink: json['pg_payment_link'],
    );
  }
}
