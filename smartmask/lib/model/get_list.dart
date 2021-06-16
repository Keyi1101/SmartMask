import 'dart:convert';
import 'product.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> getProducts() async {
  var url =
      Uri.parse("https://2pd7jss2q3.execute-api.us-east-1.amazonaws.com/dev/get");
  return http.get(url).then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode == 200) {
      final temp = json.decode(response.body);
      List<Product> data = [];
      for (var item in temp) {
        Product temp_product = Product.fromJson(item);
        data.add(temp_product);
      }
      return data;
    }
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return null;
  });
}