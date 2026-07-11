class ProfileResponseModel {
  final bool status;
  final ProfileData data;

  ProfileResponseModel({required this.status, required this.data});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      status: json['status'] ?? false,
      data: ProfileData.fromJson(json['data'] ?? {}),
    );
  }
}

class ProfileData {
  final int id;
  final String name;
  final String status;
  final AgenData? agenData;

  ProfileData({
    required this.id,
    required this.name,
    required this.status,
    this.agenData,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      agenData: json['agen_data'] != null
          ? AgenData.fromJson(json['agen_data'])
          : null,
    );
  }
}

class AgenData {
  final String bank;
  final String namaDiRekening;
  final String noRekening;

  AgenData({
    required this.bank,
    required this.namaDiRekening,
    required this.noRekening,
  });

  factory AgenData.fromJson(Map<String, dynamic> json) {
    return AgenData(
      bank: json['bank'] ?? '',
      namaDiRekening: json['nama_di_rekening'] ?? '',
      noRekening: json['no_rekening'] ?? '',
    );
  }
}
