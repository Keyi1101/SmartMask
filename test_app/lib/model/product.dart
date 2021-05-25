class Product {
  final String heartrate;
  final String temperature;
  final String movement;
  final String oxygenconc;

  const Product({
    this.heartrate,
    this.temperature,
    this.movement,
    this.oxygenconc,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      heartrate: json['heartrate'].toString(),
      temperature: json['temperature'].toString(),
      movement: json['movement'].toString(),
      oxygenconc: json['oxygenconc'].toString(),
    );
  }
}
