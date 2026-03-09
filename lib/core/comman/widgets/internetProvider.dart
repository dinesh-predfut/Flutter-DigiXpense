import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetProvider extends ChangeNotifier {
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;

  InternetProvider() {
    _init();
  }

  void _init() async {
    await checkInternet();

    _subscription =
        _connectivity.onConnectivityChanged.listen((_) async {
      await checkInternet();
    });
  }

  Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      _hasInternet =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      _hasInternet = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}