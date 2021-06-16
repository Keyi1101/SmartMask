class Product {
  final String tim;
  final String heartrate;
  final String temperature;
  final String movement;
  final String oxygenconc;
  final String rr;

  const Product({
    this.tim,
    this.heartrate,
    this.temperature,
    this.movement,
    this.oxygenconc,
    this.rr,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      tim: json['tim'].toString(),
      heartrate: json['hr'].toString(),
      temperature: json['tem'].toString(),
      movement: json['mot'].toString(),
      oxygenconc: json['spo'].toString(),
      rr: json['rr'].toString(),

    );
  }
}
