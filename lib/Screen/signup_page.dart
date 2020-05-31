import 'package:flutter/material.dart';
import '../Model/user.dart';
import '../Utils/user_database.dart';

class SignupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpState();
  }
}

class SignUpState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();
  final _nameEditController = TextEditingController();
  final _mobileEditController = TextEditingController();
  final _passwordEditController = TextEditingController();
  String password_pattern = r'^[a-zA-Z0-9]{6,}$';
  String mobile_pattern = r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$';
  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return new Scaffold(
      backgroundColor: Colors.black,
      key: _scafoldKey,
      body: Stack(
        children: <Widget>[
          // Image.asset("splash_img.png",fit: BoxFit.cover, width: size.width,height: size.height,),
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
              color: Colors.teal,
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
                          height: 20,
                        ),
                        Container(
                          decoration: new BoxDecoration(
                            border: new Border.all(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.teal,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Registration Form",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        //--------------Name FormFiled------------------------------------------
                        TextFormField(
                          controller: _nameEditController,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Enter Name";
                            }
                            return null;
                          },
                          style: getTextStyle(),
                          decoration: customInputDecoration("Enter Name"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        //--------------Mobile FormFiled------------------------------------------
                        TextFormField(
                          controller: _mobileEditController,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            RegExp regex = RegExp(mobile_pattern);
                            if (!regex.hasMatch(value))
                              return 'Enter valid mobile number';
                            else
                              return null;
                          },
                          keyboardType: TextInputType.number,
                          style: getTextStyle(),
                          decoration:
                              customInputDecoration("Enter mobile number"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        //--------------Password FormFiled------------------------------------------
                        TextFormField(
                          controller: _passwordEditController,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            RegExp regex = RegExp(password_pattern);
                            if (!regex.hasMatch(value))
                              return 'Password should be in alphanumaric with 6 characters';
                            else
                              return null;
                          },
                          obscureText: true,
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
                                  .insertUser(User(
                                      _nameEditController.text,
                                      _passwordEditController.text,
                                      _mobileEditController.text))
                                  .then((result) {
                                if (result == -1) {
                                  _scafoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                          'User with same number already existed $result')));
                                } else {
                                  _scafoldKey.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                          'User Registered Succesfully $result')));
                                  Navigator.pushReplacementNamed(
                                      context, "/login");
                                }
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.green,
                          child: Text(
                            "Signup",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),

                        FlatButton(
                          child: Text("Already have account, Sign In?"),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                        )
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
    ;
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
