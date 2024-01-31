// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:barcode_app_reader/Views/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _confirmPassController = TextEditingController();
  bool _obscureText = true;
  IconData _iconData = Icons.visibility;

  void _toggleObsecureText() {
    setState(() {
      _obscureText = !_obscureText;
      _iconData = _obscureText ? Icons.visibility : Icons.visibility_off;
    });
  }

  Future<void> _signup(BuildContext context) async {
    final String apiUrl = 'http://192.168.100.118:8084/api/User/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': 0,
          'name': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'passwordConfirmed': _confirmPassController.text,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['message']}'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

        print('Signup successful!');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);

        if (errorData.containsKey('errors')) {
          // Server returned validation errors
          final errors = errorData['errors'];
          if (errors is Map<String, dynamic>) {
            // Display errors in the UI
            errors.forEach((key, value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$value'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }
        } else {
          final Map<String, dynamic> errorData = json.decode(response.body);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${errorData['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }

        print('Signup failed. Status code: ${response.statusCode}');
        print('Response body (decoded): $errorData');
      }
    } catch (e) {
      print('Error during Signup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Form(
              key: _formKey, // Assign the global key to the Form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Please Create your account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(180, 255, 255, 255),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "Username ",
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(166, 255, 255, 255)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Username';
                        }
                        // You can add more validation logic here if needed
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "Email  ",
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(166, 255, 255, 255)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // You can add more validation logic here if needed
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      obscureText: _obscureText,
                      controller: _passwordController,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "Password",
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _toggleObsecureText();

                            // Revert the obscured text after 3 seconds (adjust the duration as needed)
                            Timer(Duration(seconds: 3), () {
                              if (mounted) {
                                _toggleObsecureText();
                              }
                            });
                          },
                          child: Icon(_iconData),
                        ),
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(166, 255, 255, 255)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        // You can add more validation logic here if needed
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      obscureText: _obscureText,
                      controller: _confirmPassController,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _toggleObsecureText();

                            // Revert the obscured text after 3 seconds (adjust the duration as needed)
                            Timer(Duration(seconds: 3), () {
                              if (mounted) {
                                _toggleObsecureText();
                              }
                            });
                          },
                          child: Icon(_iconData),
                        ),
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(166, 255, 255, 255)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-enter your password';
                        }
                        // You can add more validation logic here if needed
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _signup(context);
                      }
                    },
                    child: Text('Signup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
