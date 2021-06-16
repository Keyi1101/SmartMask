import 'package:http/http.dart' as http;

Future<void> updateName(String ID, String newItem) async {
  var url =
      Uri.parse("https://endpoint/dev/todos/$ID");
  return http
      .put(url, body: "{" + "\"item\": \"$newItem\" }")
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    print(response);
    print(statusCode);
    if (statusCode == 200) {
      print("Success");
      return;
    }else{
      throw new Exception("Error while fetching data");
    }
  });
}