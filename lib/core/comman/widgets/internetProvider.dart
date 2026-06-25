import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


class InternetProvider extends ChangeNotifier {

  bool _isConnected = true;

  bool get isConnected => _isConnected;


  late StreamSubscription subscription;


  InternetProvider(){

    checkInternet();


    subscription =
        Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result){


      if(result.contains(ConnectivityResult.none)){

        _isConnected = false;

      }else{

        _isConnected = true;

      }


      notifyListeners();

    });

  }



  Future<void> checkInternet() async {


    final result =
        await Connectivity().checkConnectivity();


    if(result.contains(ConnectivityResult.none)){

      _isConnected = false;

    }else{

      _isConnected = true;

    }


    notifyListeners();

  }



  @override
  void dispose(){

    subscription.cancel();

    super.dispose();

  }

}