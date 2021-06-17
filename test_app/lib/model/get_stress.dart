import 'dart:convert';
import 'package:test_app/model/stress.dart';

import 'product.dart';
import 'package:http/http.dart' as http;

Future<List<stressview>> getstress() async {
  var url =
      Uri.parse("https://4rb2pmbsnh.execute-api.us-east-1.amazonaws.com/dev/get");
  return http.get(url).then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode == 200) {
      final temp = json.decode(response.body);
      List<stressview> data = [];
      for (var item in temp) {
        stressview temp_product = stressview.fromJson(item);
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