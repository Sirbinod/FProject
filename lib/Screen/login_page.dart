import 'package:flutter/material.dart';
import '../Utils/user_database.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return new Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          Container(
            color: const Color(0x99FFFFFF),
          ),
          Container(
            height: 120,
            decoration: new BoxDecoration(
              border: Border.all(color: Colors.teal),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(size.width / 2),
                  topRight: Radius.circular(size.width / 2)),
              gradient: LinearGradient(
                  colors: [Color(0xfffbb448), Color(0xffe46b10)]),
            ),
          ),
          Center(
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: new BoxDecoration(
                          border: new Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              colors: [Color(0xfffbb448), Color(0xffe46b10)]),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Friend Locator",
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: _mobileFocus,
                        onFieldSubmitted: (term) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter mobile number";
                          }
                          return null;
                        },
                        style: getTextStyle(),
                        decoration:
                            customInputDecoration("Enter Mobile Number"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        focusNode: _passwordFocus,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter Password";
                          }
                          return null;
                        },
                        style: getTextStyle(),
                        decoration: customInputDecoration("Enter password"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            UserDatabase.instance
                                .checkUserLogin(_mobileController.text,
                                    _passwordController.text)
                                .then((result) {
                              if (result == null) {
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content:
                                        Text("Please enter valid details")));
                              } else {
                                Navigator.pushReplacementNamed(
                                    context, "/home");
                              }
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Colors.brown,
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                      FlatButton(
                        child: Text(
                          "Don't have account, Signup?",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/signup");
                        },
                      )
                    ],
                  )),
            )),
          )
        ]));
  }

  TextStyle getTextStyle() {
    return TextStyle(fontSize: 18, color: Colors.white);
  }

  InputDecoration customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black),
      contentPadding: EdgeInsets.all(10),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black)),
    );
  }
}
