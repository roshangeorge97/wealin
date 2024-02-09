import 'package:SmartSaver/settings_page.dart';
import 'package:SmartSaver/signup_page.dart';
import 'package:SmartSaver/summary_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Create an instance of FirebaseAuth

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? errorMessage; // Store the error message
  bool _isLoading = false;

  // Function to handle user login
  Future<void> signInWithEmailAndPassword() async {
    try {
      setState(() {
        _isLoading = true; // Start showing the progress indicator
      });

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final User? user = userCredential.user;

      setState(() {
        _isLoading = false; // Stop showing the progress indicator
      });

      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SummaryPage()),
        );
      } else {
        // Handle the case where login fails
        setState(() {
          errorMessage = 'Incorrect email or password. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop showing the progress indicator
      });

      // Handle Firebase authentication errors
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          // The user does not exist
          setState(() {
            errorMessage = 'User not Registered. Please Register.';
          });
        } else if (error.code == 'wrong-password') {
          // The password is incorrect
          setState(() {
            errorMessage = 'Wrong password. Please try again.';
          });
        } else {
          // Handle other Firebase authentication errors
          setState(() {
            errorMessage = 'An error occurred. Please try again later.';
          });
        }
      } else {
        // Handle other errors (not Firebase authentication related)
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
                  'Login',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff3aa6b9),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Please fill the credentials',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff727272),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16),
                // Display error message if set
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red, // Error message color
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
                    controller: emailController, // Use the email controller
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
                    controller: passwordController, // Use the password controller
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
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        signInWithEmailAndPassword(); // Call the function for login
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
                        'Sign In',
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
                    _resetPassword(); // Call the function to reset the password
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xff3aa6b9),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Don't have an account yet?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff727272),
                    fontFamily: 'Poppins',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    ); // Navigate to the sign-up page
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xff3aa6b9),
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

  // Function to send a password reset email
  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      // Show a dialog or message to inform the user that a reset email has been sent
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Reset Email Sent'),
            content: Text('Check your email for instructions to reset your password.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error sending reset password email: $e');
      // Handle the error (e.g., user not found) and provide appropriate feedback to the user
    }
  }
}
