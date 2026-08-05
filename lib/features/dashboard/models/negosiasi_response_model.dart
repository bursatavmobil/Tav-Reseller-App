import 'package:reseller_app_tav/features/dashboard/models/transaksi_response_model.dart';

class NegotiationResponseModel {
  final bool status;
  final String code;
  final String text;
  final String method;
  final NegotiationData data;

  NegotiationResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.method,
    required this.data,
  });

  factory NegotiationResponseModel.fromJson(Map<String, dynamic> json) {
    return NegotiationResponseModel(
      status: json['status'] ?? false,
      code: json['code'] ?? '',
      text: json['text'] ?? '',
      method: json['method'] ?? '',
      data: NegotiationData.fromJson(json['data'] ?? {}),
    );
  }
}

class NegotiationData {
  final int totalData;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String nextPageUrl;
  final List<NegotiationResult> result;

  NegotiationData({
    required this.totalData,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.nextPageUrl,
    required this.result,
  });

  factory NegotiationData.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List?;
    List<NegotiationResult> resultList = list != null
        ? list.map((i) => NegotiationResult.fromJson(i)).toList()
        : [];

    return NegotiationData(
      totalData: json['total_data'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      nextPageUrl: json['next_page_url'] ?? '',
      result: resultList,
    );
  }
}

class NegotiationResult {
  final int id;
  final int carId;
  final String bidder;
  final String bidderPhone;
  final int startingPrice;
  int negotiatedPrice;
  final String status;
  final String paymentType;
  final String? createdAt;
  final String? updatedAt;
  final String? statusNote;
  final NegotiationCar? car;
  final int? customerId;
  final NegotiationAgen? agen;
  final AgenTransaksiModel? agenTransaksi;

  NegotiationResult({
    required this.id,
    required this.carId,
    required this.bidder,
    required this.bidderPhone,
    required this.startingPrice,
    required this.negotiatedPrice,
    required this.status,
    required this.paymentType,
    this.createdAt,
    this.updatedAt,
    this.statusNote,
    this.car,
    this.customerId,
    this.agen,
    this.agenTransaksi,
  });

  factory NegotiationResult.fromJson(Map<String, dynamic> json) {
    return NegotiationResult(
      id: json['id'] ?? 0,
      carId: json['car_id'] ?? 0,
      bidder: json['bidder'] ?? '',
      bidderPhone: json['bidder_phone'] ?? '',
      startingPrice: json['starting_price'] ?? 0,
      negotiatedPrice: json['negotiated_price'] ?? 0,
      status: json['status'] ?? 'NEW',
      paymentType: json['payment_type'] ?? 'CASH',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      statusNote: json['status_note'],
      car: json['car'] != null ? NegotiationCar.fromJson(json['car']) : null,
      customerId: json['customer_id'] ?? 0,
      agen: json['agen'] != null
          ? NegotiationAgen.fromJson(json['agen'])
          : null,
      agenTransaksi: json['agen_transaksi'] != null
          ? AgenTransaksiModel.fromJson(json['agen_transaksi'])
          : null,
    );
  }
}

class NegotiationCar {
  final int id;
  final String nomorRangka;
  final String noPlat;
  final bool isLelang;
  final int nominalPembelian;
  final int creditPrice;
  final String? carCover;
  final String? carName;

  NegotiationCar({
    required this.id,
    required this.nomorRangka,
    required this.noPlat,
    required this.isLelang,
    required this.nominalPembelian,
    required this.creditPrice,
    this.carCover,
    this.carName,
  });

  factory NegotiationCar.fromJson(Map<String, dynamic> json) {
    return NegotiationCar(
      id: json['id'] ?? 0,
      carName: json['name'] ?? '',
      nomorRangka: json['nomor_rangka'] ?? '',
      noPlat: json['no_plat'] ?? '',
      isLelang: json['is_lelang'] ?? false,
      nominalPembelian: json['nominal_pembelian'] ?? 0,
      creditPrice: json['credit_price'] ?? 0,
      carCover: json['car_cover'],
    );
  }
}

class NegotiationAgen {
  final int id;
  final String name;
  final String email;
  final String? gavatar;

  NegotiationAgen({
    required this.id,
    required this.name,
    required this.email,
    this.gavatar,
  });

  factory NegotiationAgen.fromJson(Map<String, dynamic> json) {
    return NegotiationAgen(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gavatar: json['gavatar'],
    );
  }
}
