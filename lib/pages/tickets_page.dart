import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'tickets_detail_page.dart';

class TicketsPage extends StatefulWidget {
  final String userId;
  final String userRole;
  final String userPhotoUrl;

  const TicketsPage({super.key, required this.userId, required this.userRole, required this.userPhotoUrl});

  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  int _selectedIndex = 3;
  List<dynamic> _purchasedTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchasedTickets();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchPurchasedTickets() async {
    final url = 'http://10.0.2.2:8080/api/tickets/user/${widget.userId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _purchasedTickets = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching tickets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Eventra',
          userRole: widget.userRole,
          userId: widget.userId,
          userPhotoUrl: widget.userPhotoUrl,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Próximo'),
              Tab(text: 'Pasado'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _purchasedTickets.length,
              itemBuilder: (context, index) {
                final ticket = _purchasedTickets[index];
                return _buildTicketCard(
                  context,
                  ticketId: ticket['id'],
                  image: ticket['photo'],
                  title: ticket['title'],
                  date: ticket['dateTime'],
                  time: ticket['dateTime'],
                  description: ticket['description'],
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _purchasedTickets.length,
              itemBuilder: (context, index) {
                final ticket = _purchasedTickets[index];
                return _buildTicketCard(
                  context,
                  ticketId: ticket['id'],
                  image: ticket['photo'],
                  title: ticket['title'],
                  date: ticket['dateTime'],
                  time: ticket['dateTime'],
                  description: ticket['description'],
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          userId: widget.userId,
          userRole: widget.userRole,
          userPhotoUrl: widget.userPhotoUrl,
        ),
      ),
    );
  }

  Widget _buildTicketCard(
      BuildContext context, {
        required int ticketId,
        required String image,
        required String title,
        required String date,
        required String time,
        required String description,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.grey.shade200,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: SizedBox(
          width: 70,
          height: 70,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFFFFA726)),
                const SizedBox(width: 5),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Color(0xFFFFA726)),
                const SizedBox(width: 5),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailPage(
                  title: title,
                  date: date,
                  time: time,
                  image: image,
                  description: description,
                  userId: widget.userId,
                  ticketId: ticketId.toString(), // Convertir ticketId a String
                ),
              ),
            );
          },
          child: const Text('Ver Detalles', style: TextStyle(color: Color(0xFFFFA726))),
        ),
      ),
    );
  }
}