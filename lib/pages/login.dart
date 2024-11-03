import 'package:flutter/material.dart';
import 'package:eventra_app/services/api_service.dart';
import 'home_page.dart';
import 'my_events_page.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final apiService = ApiService();
    final response = await apiService.loginUser(
      _emailController.text,
      _passwordController.text,
    );

    // Print the full response for debugging
    print('Full Response: $response');

    if (response['statusCode'] == 200) {
      final user = response['body'];
      print('User email: ${user['email']}');
      print('User ID: ${user['id']}');
      print('User Role: ${user['role']}');
      print('User Photo URL: ${user['photo']}'); // Ensure this is available

      if (user['role'] == 'CLIENT') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(
            userId: user['id'].toString(),
            userRole: user['role'],
            userPhotoUrl: user['photo'] ?? '', // Pass the userPhotoUrl here
          )),
        );
      } else if (user['role'] == 'BUSINESS') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyEventsPage(
            userId: user['id'].toString(),
            userRole: user['role'],
            userPhotoUrl: user['photo'] ?? '', // Pass the userPhotoUrl here
          )),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/logo.png', // Add your logo asset here
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(
                        color: Colors.blueGrey[900],
                        decoration: TextDecoration.underline,
                      ),
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