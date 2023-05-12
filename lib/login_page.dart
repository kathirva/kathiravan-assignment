import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_app/home_page.dart';
import 'package:login_app/signup_page.dart';
import 'dart:core';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

final _auth = FirebaseAuth.instance;

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool showSpinner = false;
  bool errorEmail = false, errorPass = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          iconTheme: IconThemeData(color: Colors.black87),
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            showSpinner
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoActivityIndicator(),
                  ))
                : Container()
          ],
        ),
        body: _buildLoginWidgets());
  }

  Widget _buildLoginWidgets() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(height: 0.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Image.asset(
                "assets/app_logo.png",
                scale: 8,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Login",
                // textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(height: 50.0),
            TextField(
              onChanged: (newValue) {
                email = newValue.trim();
              },
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  errorText: errorEmail ? "Enter valid email address" : null,
                  hintText: 'Email',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26))),
            ),
            Container(height: 30.0),
            TextField(
              onChanged: (newValue) {
                password = newValue.trim();
              },
              maxLines: 1,
              // keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  errorText: errorPass ? "Enter the valid password" : null,
                  hintText: 'Password',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26))),
            ),
            InkWell(
              onTap: () {
                if (!showSpinner) {
                  setState(() {
                    showSpinner = true;
                  });
                  validateUserInput();
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: 80.0),
                padding: EdgeInsets.only(
                    left: 60.0, right: 60.0, top: 15.0, bottom: 15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  // border: Border.all(color: Colors.grey[200]),
                  color: Colors.blue,
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16.0),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 80.0),
              child: Text(
                "Don't have an account?",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: 14.0),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SignupPage()),
                    (Route<dynamic> route) => false);
              },
              child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(
                    "Signup Now",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                        fontSize: 14.0),
                  )),
            )
          ],
        ),
      ),
    );
  }

  validateUserInput() {
    // Validating user input email address
    final bool isEmailValid = EmailValidator.validate(email);
    if (!isEmailValid) {
      errorEmail = true;
    } else {
      errorEmail = false;
    }
    // Validating user input password
    if (password.length <= 0) {
      errorPass = true;
    } else {
      errorPass = false;
    }
    // Creating the account when all the validation is passed
    if (!errorEmail && !errorPass) {
      login();
    } else {
      setState(() {
        showSpinner = false;
      });
    }
  }

  login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Saving user information in local
      User? user = userCredential.user;
      String? userId = user?.uid.toString();
      String? userName = user?.displayName.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username", userName.toString());
      prefs.setString("userid", userId.toString());
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: "User not found.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[300],
            textColor: Colors.black,
            fontSize: 16.0);
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: "Incorrect Password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[300],
            textColor: Colors.black,
            fontSize: 16.0);
        print('Wrong password provided.');
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[300],
          textColor: Colors.black,
          fontSize: 16.0);
      print(e);
    }
    setState(() {
      showSpinner = false;
    });
  }
}
