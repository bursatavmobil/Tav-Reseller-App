class VisitScheduleResponseModel {
  final bool status;
  final String code;
  final String text;
  final VisitScheduleData data;

  const VisitScheduleResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.data,
  });

  factory VisitScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    return VisitScheduleResponseModel(
      status: json['status'] ?? false,
      code: json['code']?.toString() ?? '',
      text: json['text'] ?? '',
      data: VisitScheduleData.fromJson(json['data'] ?? {}),
    );
  }
}

class VisitScheduleData {
  final int totalData;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final List<VisitScheduleItem> result;

  const VisitScheduleData({
    required this.totalData,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.result,
  });

  factory VisitScheduleData.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List?;
    List<VisitScheduleItem> resultList = list != null
        ? list.map((i) => VisitScheduleItem.fromJson(i)).toList()
        : [];

    return VisitScheduleData(
      totalData: json['total_data'] ?? 0,
      perPage: json['per_page'] ?? 10,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      result: resultList,
    );
  }
}

class VisitScheduleItem {
  final int id;
  final int agenId;
  final int carId;
  final String status;
  final String tipe;
  final String namaKonsumen;
  final String tanggal;
  final String jam;
  final String catatan;
  final ScheduleCar? car;

  const VisitScheduleItem({
    required this.id,
    required this.agenId,
    required this.carId,
    required this.status,
    required this.tipe,
    required this.namaKonsumen,
    required this.tanggal,
    required this.jam,
    required this.catatan,
    this.car,
  });

  factory VisitScheduleItem.fromJson(Map<String, dynamic> json) {
    return VisitScheduleItem(
      id: json['id'] ?? 0,
      agenId: json['agen_id'] ?? 0,
      carId: json['car_id'] ?? 0,
      status: json['status'] ?? '',
      tipe: json['tipe'] ?? '',
      namaKonsumen: json['nama_konsumen'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jam: json['jam'] ?? '',
      catatan: json['catatan'] ?? '',
      car: json['car'] != null ? ScheduleCar.fromJson(json['car']) : null,
    );
  }
}

class ScheduleCar {
  final int id;
  final String name;
  final int cashPrice;
  final int creditPrice;
  final String noPlat;
  final String carCover;
  final int carYear;

  const ScheduleCar({
    required this.id,
    required this.name,
    required this.cashPrice,
    required this.creditPrice,
    required this.noPlat,
    required this.carCover,
    required this.carYear,
  });

  factory ScheduleCar.fromJson(Map<String, dynamic> json) {
    return ScheduleCar(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      cashPrice: json['cash_price'] ?? 0,
      creditPrice: json['credit_price'] ?? 0,
      noPlat: json['no_plat'] ?? '',
      carCover: json['car_cover']?? '',
      carYear: json['car_year'] ?? 0,
    );
  }
}