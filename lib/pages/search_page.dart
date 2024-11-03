import 'package:flutter/material.dart';
import 'filter_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  final String userId;
  final String userRole;
  final String userPhotoUrl;

  const SearchPage({super.key, required this.userId, required this.userRole, required this.userPhotoUrl});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int _selectedIndex = 1;
  List<dynamic> _events = [];
  List<dynamic> _filteredEvents = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterEvents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/activities'));
    if (!mounted) return;
    if (response.statusCode == 200) {
      setState(() {
        _events = jsonDecode(response.body);
        _filteredEvents = _events;
      });
    } else {
      print('Failed to load events');
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((event) {
        final name = event['name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  void _showFilterDialog() async {
    final filteredEvents = await showDialog<List<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return FiltersPage(events: _events);
      },
    );

    if (filteredEvents != null) {
      setState(() {
        _filteredEvents = filteredEvents;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Buscar',
        userRole: widget.userRole,
        userId: widget.userId,
        userPhotoUrl: widget.userPhotoUrl,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Categorías',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFA726)),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  categoryButton(Icons.music_note, 'Música'),
                  const SizedBox(width: 10),
                  categoryButton(Icons.theater_comedy, 'Teatro'),
                  const SizedBox(width: 10),
                  categoryButton(Icons.sports_soccer, 'Deportes'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Eventos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFA726)),
            ),
            const SizedBox(height: 10),
            ..._filteredEvents.map((event) => eventCard(
              event['name'] ?? 'No name',
              event['fechas_eventos']?.isNotEmpty == true ? event['fechas_eventos'][0].split('T')[0] : 'No date',
              event['fechas_eventos']?.isNotEmpty == true ? event['fechas_eventos'][0].split('T')[1] : 'No time',
              event['photo'] ?? 'https://via.placeholder.com/150',
            )).toList(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        userId: widget.userId,
        userRole: widget.userRole,
        userPhotoUrl: widget.userPhotoUrl,
      ),
    );
  }

  Widget categoryButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA726),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget eventCard(String title, String date, String time, String imagePath) {
    final validImagePath = Uri.tryParse(imagePath)?.hasAbsolutePath == true ? imagePath : 'https://via.placeholder.com/150';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(validImagePath, width: 80, fit: BoxFit.cover),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(time, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Ver', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}