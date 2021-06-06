import 'package:test_app/model/get_list.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

Future<void> createItem(Product product) async {
  var url = Uri.parse("https://2pd7jss2q3.execute-api.us-east-1.amazonaws.com/dev/post");
  return http
      .post(url,
          body: "{" +
              "\"tim\": \"${product.tim}\", "
                  "\"heartrate\": \"${product.heartrate}\", "
                  "\"temperature\": \"${product.temperature}\", "
                  "\"movement\": \"${product.movement}\", "
                  "\"oxygenconc\": \"${product.oxygenconc}\", "
                  "\"rr\": \"${product.rr}\" }")

      .then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode == 200) {
      return;
    } else {
      throw new Exception("Error while fetching data");
    }
  });
}
