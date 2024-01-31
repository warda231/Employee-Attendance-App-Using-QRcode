// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_brace_in_string_interps



import 'package:barcode_app_reader/Views/HomePage.dart';
import 'package:barcode_app_reader/Views/SignupScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = _decodeBase64(parts[1]);
    final Map<String, dynamic> payloadMap = json.decode(payload);

    return payloadMap;
  }

  String _decodeBase64(String input) {
    String output = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64 string');
    }

    return utf8.decode(base64Url.decode(output));
  }

  Future<void> _login(BuildContext context) async {
    final String apiUrl = 'http://192.168.100.118:8084/api/User/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['token'];
        final Map<String, dynamic> decodedToken = parseJwt(token);
        print('Decoded Token: $decodedToken');
        List<String> userRoles = [];
        if (decodedToken != null &&
            decodedToken.containsKey(
                'http://schemas.microsoft.com/ws/2008/06/identity/claims/role')) {
          var rolesClaim = decodedToken[
              'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
          if (rolesClaim is String) {
            // Convert the single string to a list
            userRoles = [rolesClaim];
          } else if (rolesClaim is List<dynamic>) {
            userRoles = rolesClaim.cast<String>();
          }
        } else {
          print('Error during login: Roles field is missing or null in JWT.');
        }
        print('Token: $token');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (userRoles.contains('ADMIN') && userRoles.contains('USER')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(username: _emailController.text)),
          );
        } else if (userRoles.contains('USER')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(username: _emailController.text)),
          );
        }
        print('Login successful!');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);

        if (errorData.containsKey('errors')) {
          final errors = errorData['errors'];
          if (errors is Map<String, dynamic>) {
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
        print('Login failed. Status code: ${response.statusCode}');

        print('Response body (decoded): ${errorData}');
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Form(
          key: _formKey, // Assign the global key to the Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome back!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Text(
                "Please login to your account",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Username ",
                    hintStyle: TextStyle(
                        color:  const Color.fromARGB(189, 255, 255, 255)),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Password",
            
                    hintStyle: TextStyle(
                      
                        color: const Color.fromARGB(181, 255, 255, 255)),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login(context);
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an Account?",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      'Signup',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 189, 225, 255),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
