class ServiceModel {
  final String? id;
  final String name;
  final int durationMinutes;
  final double price;

  ServiceModel({
    this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      durationMinutes: json['duration_minutes'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'duration_minutes': durationMinutes,
      'price': price,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
