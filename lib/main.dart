import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:diginexa/theme/theme.dart';

import 'package:diginexa/l10n/app_localizations.dart';

import 'package:diginexa/core/constant/Parames/params.dart';

import 'package:diginexa/core/comman/widgets/internetProvider.dart';
import 'package:diginexa/core/comman/widgets/internetWrap.dart';

import 'package:diginexa/data/pages/screen/screenLoader.dart';

import 'package:diginexa/data/pages/screen/widget/router/router.dart';

import 'package:diginexa/data/pages/screen/ALl_Expense_Screens/Reports/notifiarModels.dart';




// Navigator Key
final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();





// ================= Locale =================


class LocaleNotifier extends ChangeNotifier {


  Locale _locale;


  Locale get locale => _locale;



  LocaleNotifier.initial(this._locale);



  Future<void> setLocale(Locale locale) async {


    _locale = locale;

    notifyListeners();


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.setString(
      "LanguageID",
      getIdFromLocale(locale),
    );


  }




  String getIdFromLocale(Locale locale){


    switch(locale.languageCode){


      case "ar":
        return "LUG-02";


      case "zh":
        return "LUG-03";


      case "fr":
        return "LUG-04";


      default:
        return "LUG-01";


    }

  }


}




String getLocaleCodeFromId(String id){


  switch(id){


    case "LUG-02":
      return "ar";


    case "LUG-03":
      return "zh";


    case "LUG-04":
      return "fr";


    default:
      return "en";


  }

}






// ================= Theme Colors =================



final Map<String,Color> themeColorMap = {


"RED_THEME":Colors.pinkAccent,

"GREEN_THEME":Colors.green,

"BLUE_THEME":Colors.blue,

"ORANGE_THEME":Colors.orange,

"PURPLE_THEME":Colors.purple,

"INDIGO_THEME":Colors.indigo,


};






// ================= App Init =================



class AppInitData{


final ThemeNotifier themeNotifier;

final LocaleNotifier localeNotifier;

final String initialRoute;



AppInitData({

required this.themeNotifier,

required this.localeNotifier,

required this.initialRoute,

});


}






class AppInitializer{



static Future<AppInitData> initialize() async{


WidgetsFlutterBinding.ensureInitialized();



// Firebase


try{


await Firebase.initializeApp(

options:
DefaultFirebaseOptions.currentPlatform,

);


}catch(e){


print(
"Firebase Error $e"
);


}





final prefs =
await SharedPreferences.getInstance();



final themeKey =
prefs.getString("ThemeColor");



final langId =
prefs.getString("LanguageID")
?? "LUG-01";



final refreshToken =
prefs.getString("refresh_token");





final route =
await getInitialRoute(refreshToken);






final initialColor =

themeColorMap[themeKey]
??
const Color(0xff1A237E);






final themeNotifier =
ThemeNotifier(

ThemeData(

useMaterial3:true,

colorScheme:
ColorScheme.fromSeed(
seedColor: initialColor,
),

),

null,

);





final localeNotifier =

LocaleNotifier.initial(

Locale(
getLocaleCodeFromId(langId)
)

);







return AppInitData(

themeNotifier:
themeNotifier,


localeNotifier:
localeNotifier,


initialRoute:
route,


);



}







static Future<String> getInitialRoute(
String? token
) async{


final prefs =
await SharedPreferences.getInstance();



final lastRoute =
prefs.getString("last_route");



print("Last Route $lastRoute");

print("Token $token");




if(lastRoute=="Login"){


return AppRoutes.signin;


}




if(token==null ||
token.isEmpty ||
token=="null"){


return AppRoutes.entryScreen;


}




return AppRoutes.dashboard_Main;


}





}









// ================= MAIN =================




void main() {


WidgetsFlutterBinding.ensureInitialized();



runApp(

FutureBuilder<AppInitData>(


future:
AppInitializer.initialize(),



builder:(context,snapshot){



if(snapshot.connectionState ==
ConnectionState.waiting){



return const MaterialApp(

debugShowCheckedModeBanner:false,

home:Logo_ScreenLanding(),

);


}






if(snapshot.hasError ||
!snapshot.hasData){



return const MaterialApp(

home:Scaffold(

body:
Center(
child:
Text(
"Initialization Failed"
),
),

),

);


}







final data =
snapshot.data!;







return MultiProvider(



providers:[



ChangeNotifierProvider.value(

value:data.themeNotifier,

),





ChangeNotifierProvider.value(

value:data.localeNotifier,

),






ChangeNotifierProvider(

create:(_)=>ReportModel(),

),





ChangeNotifierProvider(

create:(_)=>InternetProvider(),

),





],






child:

MyApp(

initialRoute:
data.initialRoute,

),





);







},


),



);


}











// ================= APP =================





class MyApp extends StatelessWidget{


final String initialRoute;



const MyApp({

super.key,

required this.initialRoute,

});






@override
Widget build(BuildContext context){



final theme =
Provider.of<ThemeNotifier>(context);



final locale =
Provider.of<LocaleNotifier>(context);





return MaterialApp(



title:
"Diginexa",




debugShowCheckedModeBanner:false,




navigatorKey:
navigatorKey,




initialRoute:
initialRoute,





onGenerateRoute:
(settings){


return AppRoutes.generateRoute(settings);


},





theme:
theme.theme,





locale:
locale.locale,





supportedLocales:
const [


Locale("en"),

Locale("ar"),

Locale("fr"),

Locale("zh"),


],





localizationsDelegates:
const [



AppLocalizations.delegate,

GlobalMaterialLocalizations.delegate,

GlobalWidgetsLocalizations.delegate,

GlobalCupertinoLocalizations.delegate,


],






builder:(context,child){



return InternetWrapper(

child:
child ?? const SizedBox(),

);



},






);



}



}