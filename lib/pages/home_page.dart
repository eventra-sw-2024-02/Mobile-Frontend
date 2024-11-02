import 'package:eventra_app/pages/add_event_page.dart';
import 'package:flutter/material.dart';
import 'event_detail_page.dart';
import 'tickets_page.dart';
import 'search_page.dart';
import 'reservation_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Import intl package for DateFormat
import 'package:eventra_app/pages/login.dart'; // Import LoginPage

class HomePage extends StatefulWidget {
  final String userId;
  final String userRole;
  const HomePage({super.key, required this.userId, required this.userRole});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _trendingEvents = [];
  List<Map<String, dynamic>> _discoverEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/activities'); // Adjust the endpoint if necessary
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> activities = jsonDecode(response.body);
      print('Fetched activities: $activities'); // Debug statement
      setState(() {
        _trendingEvents = activities
            .where((activity) => [1, 2, 11, 14].contains(activity['id']))
            .map((activity) => activity as Map<String, dynamic>)
            .toList();
        _discoverEvents = activities
            .where((activity) => [12, 13].contains(activity['id']))
            .map((activity) => activity as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
      print('Trending events: $_trendingEvents'); // Debug statement
      print('Discover events: $_discoverEvents'); // Debug statement
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Failed to load activities');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SearchPage(userId: widget.userId, userRole: widget.userRole)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddEventPage(userId: widget.userId, userRole: widget.userRole)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReservationPage(userId: widget.userId, userRole: widget.userRole)),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TicketsPage(userId: widget.userId, userRole: widget.userRole)),
      );
    } else if (index == 5) {
      _showBottomSheet();
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.black87),
                title: const Text('Cambiar cuenta'),
                onTap: () {
                  // Implementa la lógica para cambiar la cuenta
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: Colors.black87),
                title: const Text('Ayuda'),
                onTap: () {
                  // Implementa la lógica para la ayuda
                },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.black87),
                title: const Text('Términos y condiciones'),
                onTap: () {
                  // Implementa la lógica para los términos y condiciones
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Eventra',
        userRole: widget.userRole,
        userId: widget.userId,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, user!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFFFA726)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Próximos eventos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFA726)),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _discoverEvents.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildUpcomingEventCard(context, event['photo'], event['name'], event['id']),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Eventos populares',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFA726)),
            ),
            const SizedBox(height: 10),
            Column(
              children: _trendingEvents.map((event) {
                return _buildPopularEventTile(context, event['name'], event['fechas_eventos'][0], '6:00 pm', event['photo'], event['id']);
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userId: widget.userId,
        userRole: widget.userRole,
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context, String imagePath, String title, int eventId) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: const Color(0xFFFFA726).withOpacity(0.2),
      child: SizedBox(
        width: 200,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imagePath, fit: BoxFit.cover, height: 100, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFFFA726)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventDetailPage(imagePath: imagePath, title: title, userId: widget.userId, userRole: widget.userRole, eventId: eventId)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Inscríbete', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularEventTile(BuildContext context, String title, String date, String time, String imagePath, int eventId) {
    return Card(
      color: const Color(0xFFFFA726),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(imagePath, width: 80, fit: BoxFit.cover),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                const SizedBox(width: 5),
                Text(DateFormat('dd MMMM').format(DateTime.parse(date)), style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.white),
                const SizedBox(width: 5),
                Text(time, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventDetailPage(imagePath: imagePath, title: title, userId: widget.userId, userRole: widget.userRole, eventId: eventId)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Ver', style: TextStyle(color: Color(0xFFFFA726))),
        ),
      ),
    );
  }
}