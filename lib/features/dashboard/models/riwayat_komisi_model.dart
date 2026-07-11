class RiwayatKomisiResponseModel {
  final bool status;
  final String code;
  final String text;
  final KomisiData data;

  const RiwayatKomisiResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.data,
  });

  factory RiwayatKomisiResponseModel.fromJson(Map<String, dynamic> json) {
    return RiwayatKomisiResponseModel(
      status: json['status'] ?? false,
      code: json['code']?.toString() ?? '',
      text: json['text'] ?? '',
      data: KomisiData.fromJson(json['data'] ?? {}),
    );
  }
}

class KomisiData {
  final int totalData;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final List<KomisiItem> result;

  const KomisiData({
    required this.totalData,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.result,
  });

  factory KomisiData.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List?;
    List<KomisiItem> resultList = list != null
        ? list.map((i) => KomisiItem.fromJson(i)).toList()
        : [];

    return KomisiData(
      totalData: json['total_data'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      result: resultList,
    );
  }
}

class KomisiItem {
  final int id;
  final int agenId;
  final int orderId;
  final int nominal;
  final String createdAt;
  final String updatedAt;
  final KomisiOrder? order;

  const KomisiItem({
    required this.id,
    required this.agenId,
    required this.orderId,
    required this.nominal,
    required this.createdAt,
    required this.updatedAt,
    this.order,
  });

  factory KomisiItem.fromJson(Map<String, dynamic> json) {
    return KomisiItem(
      id: json['id'] ?? 0,
      agenId: json['agen_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      nominal:
          json['nominal'] ??
          0, // Dipastikan int untuk kalkulasi akumulasi overview
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      order: json['order'] != null ? KomisiOrder.fromJson(json['order']) : null,
    );
  }
}

class KomisiOrder {
  final int id;
  final int reservationId;
  final String createdAt;
  final String orderType;
  final KomisiCar? car;

  const KomisiOrder({
    required this.id,
    required this.reservationId,
    required this.createdAt,
    required this.orderType,
    this.car,
  });

  factory KomisiOrder.fromJson(Map<String, dynamic> json) {
    return KomisiOrder(
      id: json['id'] ?? 0,
      reservationId: json['reservation_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      orderType: json['order_type'] ?? '',
      car: json['car'] != null ? KomisiCar.fromJson(json['car']) : null,
    );
  }
}

class KomisiCar {
  final int id;
  final String name;
  final String currentMileage;
  final String carCover;

  const KomisiCar({
    required this.id,
    required this.name,
    required this.currentMileage,
    required this.carCover,
  });

  factory KomisiCar.fromJson(Map<String, dynamic> json) {
    return KomisiCar(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      currentMileage: json['current_mileage'] ?? '',
      carCover: json['car_cover'] ?? '',
    );
  }
}
