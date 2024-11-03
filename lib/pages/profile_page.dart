import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String userRole;

  const ProfilePage({super.key, required this.userId, required this.userRole});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _userData = {};
  bool _isPasswordVisible = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/users/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          _userData = jsonDecode(response.body);
          _isLoading = false;
        });
        print('User data loaded: $_userData');
      } else {
        print('Failed to load user data: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFFFA726),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFA726)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _userData['photo'] != null
                      ? NetworkImage(_userData['photo'])
                      : AssetImage('assets/user_profile.png') as ImageProvider,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _userData['username'] ?? 'Cargando...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _userData['email'] ?? 'Cargando...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Divider(color: Colors.black54),
              const SizedBox(height: 10),
              _buildPasswordTile(context),
              _buildInfoTile(Icons.person, widget.userRole, context),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage(
                        userId: widget.userId,
                        userRole: widget.userRole,
                        userPhotoUrl: _userData['photo'], // Pass the userPhotoUrl here
                      )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTile(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(
          Icons.lock,
          color: const Color(0xFFFFA726),
          size: 30,
        ),
        title: Text(
          _isPasswordVisible ? (_userData['password'] ?? 'Cargando...') : '********',
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        trailing: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFFFFA726),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFA726),
          size: 30,
        ),
        title: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}