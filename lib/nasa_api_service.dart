import 'package:http/http.dart' as http;

const _apiAuthority = "api.nasa.gov";
const _apiEndPoint = "/planetary/apod";

class NasaApiService {
  final String _apiKey;

  NasaApiService(this._apiKey);

  Future<String> getAPODList(DateTime startDate) async {
    final dateStr = "${startDate.year}-${startDate.month}-${startDate.day}";
    final queryParameters = {
      "api_key": _apiKey,
      "start_date": dateStr,
    };

    final response = await http.get(Uri.https(_apiAuthority, _apiEndPoint, queryParameters));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load APOD data: ${response.statusCode}:${response.reasonPhrase}');
    }
  }
}
