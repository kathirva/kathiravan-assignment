import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_app/home_page.dart';
import 'package:login_app/login_page.dart';
import 'dart:core';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

//code for designing the UI of our text field where the user writes his email id or password

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  String name = "";
  String email = "";
  String password = "";
  bool showSpinner = false;
  bool errorName = false, errorEmail = false, errorPass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black87),
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            showSpinner
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoActivityIndicator(),
                  ))
                : Container()
          ],
        ),
        body: _buildSignupWidgets());
  }

  Widget _buildSignupWidgets() {
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
                // color: colors("highlight"),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Signup",
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
                name = newValue.trim();
              },
              maxLines: 1,
              keyboardType: TextInputType.name,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  errorText: errorName ? "Enter a valid name" : null,
                  hintText: 'Name',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26))),
            ),
            Container(height: 30.0),
            TextField(
              onChanged: (newValue) {
                email = newValue.trim();
              },
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  errorText: errorEmail ? "Enter a valid email address" : null,
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
                  errorText: errorPass
                      ? "Password need to be at least 8 characters."
                      : null,
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
                  "Signup",
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
                "Already have an account?",
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
                        builder: (BuildContext context) => LoginPage()),
                    (Route<dynamic> route) => false);
              },
              child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(
                    "Login Now",
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
    // Validating user input name
    if (name.length <= 1 || double.tryParse(name) is double) {
      errorName = true;
    } else {
      errorName = false;
    }
    // Validating user input email address
    final bool isEmailValid = EmailValidator.validate(email);
    if (!isEmailValid) {
      errorEmail = true;
    } else {
      errorEmail = false;
    }
    // Validating user input password
    if (password.length < 8) {
      errorPass = true;
    } else {
      errorPass = false;
    }
    // Creating the account when all the validation is passed
    if (!errorName && !errorEmail && !errorPass) {
      createNewAccount();
    } else {
      setState(() {
        showSpinner = false;
      });
    }
  }

  createNewAccount() async {
    // Create new user account in Firebase
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(name);

      // Saving user information in local
      User? user = userCredential.user;
      String? userId = user?.uid.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("username", name);
      prefs.setString("userid", userId.toString());
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          (Route<dynamic> route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "The password provided is too weak.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[300],
            textColor: Colors.black,
            fontSize: 16.0);
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "The account already exists for that email.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[300],
            textColor: Colors.black,
            fontSize: 16.0);
        print('The account already exists for that email.');
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
