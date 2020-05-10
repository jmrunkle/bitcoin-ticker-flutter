import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const List<String> currenciesList = [
  'AUD',
  'BRL',
  'CAD',
  'CNY',
  'EUR',
  'GBP',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'JPY',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'RON',
  'RUB',
  'SEK',
  'SGD',
  'USD',
  'ZAR'
];

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'LTC',
];

class CoinData {
  static const String apiKey = '25195643-B238-479F-9D38-C298D0BF571E';
  static const String urlBase = 'https://rest-sandbox.coinapi.io';

  Future<double> getCoinData({String crypto, String currency}) async {
    http.Response response =
        await http.get('$urlBase/v1/exchangerate/$crypto/$currency', headers: {
      'X-CoinAPI-Key': apiKey,
      'Accept': 'application/json',
      'Accept-Encoding': 'deflate, gzip',
    });

    if (response.statusCode == 200) {
      String content = extractContent(response);
      return json.decode(content)['rate'];
    } else {
      print('Error getting exchange rate: '
          'statusCode=${response.statusCode} reason=${response.reasonPhrase}');
      return null;
    }
  }

  String extractContent(http.Response response) {
    List<int> decompressedBytes;
    switch (response.headers['Content-Encoding']) {
      case 'deflate':
        decompressedBytes = zlib.decode(response.bodyBytes);
        break;
      case 'gzip':
        decompressedBytes = gzip.decode(response.bodyBytes);
        break;
      default:
        return response.body;
    }
    return utf8.decode(decompressedBytes);
  }
}
