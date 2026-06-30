import 'package:flutter/material.dart';


class NoInternetPage extends StatelessWidget {


  final VoidCallback onRetry;


  const NoInternetPage({
    super.key,
    required this.onRetry,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: Center(


        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children: [


            const Icon(
              Icons.wifi_off,
              size:80,
            ),


            const SizedBox(height:20),


            const Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize:20,
                fontWeight:FontWeight.bold,
              ),
            ),



            const SizedBox(height:20),



            ElevatedButton(


              onPressed:onRetry,


              child:
              const Text("Retry"),


            )



          ],

        ),

      ),

    );


  }


}