class PenarikanResponseModel {
  final bool status;
  final String code;
  final String text;
  final PenarikanData data;

  const PenarikanResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.data,
  });

  factory PenarikanResponseModel.fromJson(Map<String, dynamic> json) {
    return PenarikanResponseModel(
      status: json['status'] ?? false,
      code: json['code']?.toString() ?? '',
      text: json['text'] ?? '',
      data: PenarikanData.fromJson(json['data'] ?? {}),
    );
  }
}

class PenarikanData {
  final int totalData;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final List<PenarikanItem> result;

  const PenarikanData({
    required this.totalData,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.result,
  });

  factory PenarikanData.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List?;
    List<PenarikanItem> resultList = list != null
        ? list.map((i) => PenarikanItem.fromJson(i)).toList()
        : [];

    return PenarikanData(
      totalData: json['total_data'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      result: resultList,
    );
  }
}

class PenarikanItem {
  final int id;
  final int agenId;
  final String status;
  final int nominal;
  final String bank;
  final String namaDiRekening;
  final String noRekening;
  final String createdAt;
  final String updatedAt;

  const PenarikanItem({
    required this.id,
    required this.agenId,
    required this.status,
    required this.nominal,
    required this.bank,
    required this.namaDiRekening,
    required this.noRekening,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PenarikanItem.fromJson(Map<String, dynamic> json) {
    return PenarikanItem(
      id: json['id'] ?? 0,
      agenId: json['agen_id'] ?? 0,
      status: json['status'] ?? '',
      nominal: json['nominal'] ?? 0,
      bank: json['bank'] ?? '',
      namaDiRekening: json['nama_di_rekening'] ?? '',
      noRekening: json['no_rekening']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
