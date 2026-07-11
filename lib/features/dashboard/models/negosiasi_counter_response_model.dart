class NegotiationCounterResponseModel {
  final bool status;
  final String code;
  final String text;
  final String method;
  final List<NegotiationCounterItem> data;

  NegotiationCounterResponseModel({
    required this.status,
    required this.code,
    required this.text,
    required this.method,
    required this.data,
  });

  factory NegotiationCounterResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List?;
    List<NegotiationCounterItem> dataList = list != null
        ? list.map((i) => NegotiationCounterItem.fromJson(i)).toList()
        : [];

    return NegotiationCounterResponseModel(
      status: json['status'] ?? false,
      code: json['code'] ?? '',
      text: json['text'] ?? '',
      method: json['method'] ?? '',
      data: dataList,
    );
  }
}

class NegotiationCounterItem {
  final String status;
  final int total;

  NegotiationCounterItem({required this.status, required this.total});

  factory NegotiationCounterItem.fromJson(Map<String, dynamic> json) {
    return NegotiationCounterItem(
      status: json['status'] ?? '',
      total: json['total'] ?? 0,
    );
  }
}
