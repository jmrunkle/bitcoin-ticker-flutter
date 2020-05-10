import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'coin_data.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  Map<String, String> ratesByCrypto = {};
  CoinData coinData = CoinData();

  @override
  void initState() {
    super.initState();
    updateRates();
  }

  void initRates() {
    cryptoList.forEach((crypto) => ratesByCrypto[crypto] = '?');
  }

  void updateRates() {
    initRates();
    cryptoList.forEach(updateRate);
  }

  void updateRate(String crypto) async {
    double rate = await coinData.getCoinData(
      crypto: crypto,
      currency: selectedCurrency,
    );
    String rateAsString = rate == null ? '?' : rate.truncate().toString();
    setState(() {
      ratesByCrypto[crypto] = rateAsString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cryptoList.map(cryptoCard).toList(),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? getIosPicker() : getDefaultPicker(),
          ),
        ],
      ),
    );
  }

  Widget cryptoCard(String crypto) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
          child: Text(
            '1 $crypto = ${ratesByCrypto[crypto]} $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // To prevent a flood of calls when using the cupertino picker, we need
  // to use a timer to make sure we only send one after the user has settled
  // on a particular value for at least 2 seconds
  Timer cupertinoPickerTimer;

  Widget getIosPicker() => CupertinoPicker(
        backgroundColor: Colors.lightBlue,
        itemExtent: 40.0,
        children: currenciesList.map(makeIosCurrency).toList(),
        onSelectedItemChanged: (index) {
          if (cupertinoPickerTimer != null) {
            cupertinoPickerTimer.cancel();
          }
          cupertinoPickerTimer = Timer(Duration(seconds: 2), () {
            setState(() {
              selectedCurrency = currenciesList[index];
              updateRates();
            });
            cupertinoPickerTimer = null;
          });
        },
      );

  Widget makeIosCurrency(String currency) => Text(currency);

  Widget getDefaultPicker() => DropdownButton<String>(
        value: selectedCurrency,
        items: currenciesList.map(makeCurrencyItem).toList(),
        onChanged: (value) => setState(() {
          selectedCurrency = value;
          updateRates();
        }),
      );

  DropdownMenuItem<String> makeCurrencyItem(String currency) =>
      DropdownMenuItem(
        value: currency,
        child: Text(currency),
      );
}
