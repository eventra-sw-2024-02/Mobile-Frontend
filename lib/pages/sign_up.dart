import 'package:flutter/material.dart';
import 'package:eventra_app/services/api_service.dart';
import '../main.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _reasonSocialController = TextEditingController();
  final TextEditingController _comercialNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedCountry = 'Bangladesh';
  int _selectedRoleIndex = 0;

  @override
  void dispose() {
    _dobController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _rucController.dispose();
    _dniController.dispose();
    _reasonSocialController.dispose();
    _comercialNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final apiService = ApiService();
    final userData = {
      'username': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'role': _selectedRoleIndex == 0 ? 'CLIENT' : 'BUSINESS',
      'phone': _phoneController.text,
      'address': _addressController.text,
      if (_selectedRoleIndex == 0) 'dni': _dniController.text,
      if (_selectedRoleIndex == 0) 'dob': _dobController.text,
      if (_selectedRoleIndex == 0) 'gender': _selectedGender,
      if (_selectedRoleIndex == 0) 'country': _selectedCountry,
      if (_selectedRoleIndex == 1) 'businessName': _businessNameController.text,
      if (_selectedRoleIndex == 1) 'ruc': _rucController.text,
      if (_selectedRoleIndex == 1) 'reasonSocial': _reasonSocialController.text,
      if (_selectedRoleIndex == 1) 'comercialName': _comercialNameController.text,
      if (_selectedRoleIndex == 1) 'category': _categoryController.text,
    };

    final response = await apiService.registerUser(userData);

    if (response['statusCode'] == 200 || response['statusCode'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered Successfully')),
      );
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const EventraApp()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFFFFA726),
                  color: Colors.black,
                  constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
                  isSelected: [_selectedRoleIndex == 0, _selectedRoleIndex == 1],
                  onPressed: (int index) {
                    setState(() {
                      _selectedRoleIndex = index;
                    });
                  },
                  children: const [
                    Text('Client'),
                    Text('Business'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Name*'),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Password*', obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email*', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone*', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address*'),
              const SizedBox(height: 16),
              if (_selectedRoleIndex == 0) ...[
                _buildTextField(_dniController, 'DNI*'),
                const SizedBox(height: 16),
                _buildTextField(_dobController, 'Date of Birth*', keyboardType: TextInputType.datetime),
                const SizedBox(height: 16),
              ],
              if (_selectedRoleIndex == 1) ...[
                _buildTextField(_businessNameController, 'Business Name*'),
                const SizedBox(height: 16),
                _buildTextField(_rucController, 'RUC*'),
                const SizedBox(height: 16),
                _buildTextField(_reasonSocialController, 'Reason Social*'),
                const SizedBox(height: 16),
                _buildTextField(_comercialNameController, 'Comercial Name*'),
                const SizedBox(height: 16),
                _buildTextField(_categoryController, 'Category*'),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }
}