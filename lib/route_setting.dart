import 'package:flutter/material.dart';
import './Screen/home_page.dart';
import 'Screen/signup_page.dart';

import 'Screen/login_page.dart';

class MyApp extends StatelessWidget {
  int login;
  // MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.pink),
      //home: Homepage(),
      onGenerateRoute: RouteSettngsPage.generateRoute,
    );
  }
}

class RouteSettngsPage extends RouteSettings {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => LoginPage());
        break;
      case "/login":
        return MaterialPageRoute(builder: (_) => LoginPage());
        break;
      case "/signup":
        return MaterialPageRoute(builder: (_) => SignupPage());
        break;
      case "/home":
        return MaterialPageRoute(builder: (_) => Home());
        break;
    }
  }
}
