import 'package:SmartSaver/summary_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  String? errorMessage;
  bool _isLoading = false;

  Future<void> registerWithEmailAndPassword() async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final phoneNumber = phoneNumberController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        errorMessage = 'Invalid email format. Please enter a valid email address.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must have at least 6 characters.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match. Please re-enter passwords.';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        await _database.ref().child("users").child(user.uid).set({
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SummaryPage()),
        );
      } else {
        print('Registration failed');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (error is FirebaseAuthException) {
        if (error.code == 'email-already-in-use') {
          setState(() {
            errorMessage = 'Email is already in use. Please use a different email.';
          });
        } else {
          setState(() {
            errorMessage = 'An error occurred. Please try again later.';
          });
        }
      } else {
        print('Error: $error');
        setState(() {
          errorMessage = 'An unexpected error occurred. Please try again later.';
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff3AA6B9),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff727272),
                    fontFamily: 'Poppins',
                  ),
                ),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                SizedBox(height: 32),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xffb2f3f3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Color(0xff3AA6B9)),
                      labelStyle: TextStyle(
                        color: Color(0xff3AA6B9),
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xffb2f3f3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xff3AA6B9)),
                      labelStyle: TextStyle(
                        color: Color(0xff3AA6B9),
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xffb2f3f3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Color(0xff3AA6B9)),
                      labelStyle: TextStyle(
                        color: Color(0xff3AA6B9),
                        fontFamily: 'Poppins',
                      ),
                      suffixIcon: IconButton(
                        icon: _isPasswordVisible
                            ? Icon(Icons.visibility_off, color: Color(0xff3AA6B9))
                            : Icon(Icons.visibility, color: Color(0xff3AA6B9)),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xffb2f3f3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock, color: Color(0xff3AA6B9)),
                      labelStyle: TextStyle(
                        color: Color(0xff3AA6B9),
                        fontFamily: 'Poppins',
                      ),
                      suffixIcon: IconButton(
                        icon: _isConfirmPasswordVisible
                            ? Icon(Icons.visibility_off, color: Color(0xff3AA6B9))
                            : Icon(Icons.visibility, color: Color(0xff3AA6B9)),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                    obscureText: !_isConfirmPasswordVisible,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xffb2f3f3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone, color: Color(0xff3AA6B9)),
                      labelStyle: TextStyle(
                        color: Color(0xff3AA6B9),
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        registerWithEmailAndPassword();
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all(Size(300, 50)),
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xff3AA6B9)),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    if (_isLoading)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xff3AA6B9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
