import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventra_app/services/api_service.dart'; // Update with your actual path
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventra_app/widgets/custom_app_bar.dart';
import 'package:eventra_app/widgets/custom_bottom_navigation_bar.dart';

class MyEventsPage extends StatefulWidget {
  final String userId;
  final String userRole;
  const MyEventsPage({super.key, required this.userId, required this.userRole});

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<Map<String, dynamic>> _userActivities = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();
  int _currentIndex = 0;
  String? _selectedActivityType;

  @override
  void initState() {
    super.initState();
    _fetchUserActivities();
  }

  Future<void> _fetchUserActivities() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/activities'); // Adjust the endpoint if necessary
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> activities = jsonDecode(response.body);
      setState(() {
        _userActivities = activities.map((activity) => activity as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Failed to load activities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mis Actividades',
        userRole: widget.userRole,
        userId: widget.userId,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userActivities.isEmpty
          ? const Center(
        child: Text(
          'No activities found',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _userActivities.length,
        itemBuilder: (context, index) {
          final activity = _userActivities[index];
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  activity['photo'] != null
                      ? Image.network(
                    activity['photo'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    height: 200,
                    color: Colors.grey,
                    child: const Center(
                      child: Text(
                        'No Image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['name'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFA726),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Descripción: ${activity['description'] ?? 'No Description'}',
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ubicación: ${activity['location'] ?? 'No Location'}',
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fecha: ${activity['fechas_eventos'] != null ? DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(activity['fechas_eventos'][0])) : 'No Date'}',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Categoría: ${activity['tags'] != null ? activity['tags'].join(', ') : 'No Tags'}',
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        userId: widget.userId,
        userRole: widget.userRole,
      ),
    );
  }
}