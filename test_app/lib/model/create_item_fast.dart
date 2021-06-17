import 'package:test_app/model/get_list.dart';
import 'fastp.dart';
import 'package:http/http.dart' as http;

Future<void> createItemfast(fastproduct productf) async {
  var url = Uri.parse("https://78lmif2g6h.execute-api.us-east-1.amazonaws.com/dev/post");
  return http
      .post(url,
          body: "{" +
              "\"tim\": \"${productf.tim}\", "
                  "\"mode\": \"${productf.mode}\", "
                  "\"ppgir\": \"${productf.ppgir}\", "
                  "\"ppgred\": \"${productf.ppgred}\", "
                  "\"tresp\": \"${productf.tresp}\", "
                  "\"tskin\": \"${productf.tskin}\", "
                  "\"tenv\": \"${productf.tenv}\", "
                  "\"accelx\": \"${productf.accelx}\", "
                  "\"accely\": \"${productf.accely}\", "
                  "\"accelz\": \"${productf.accelz}\" }")

      .then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode == 200) {
      return;
    } else {
      throw new Exception("Error while fetching data");
    }
  });
}
