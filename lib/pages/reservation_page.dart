import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class ReservationPage extends StatefulWidget {
  final String userId;
  final String userRole;
  final String userPhotoUrl; // Add this parameter

  const ReservationPage({super.key, required this.userId, required this.userRole, required this.userPhotoUrl});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  int _selectedIndex = 4; // Ensure the index corresponds to the current tab

  // List of reservations
  List<Map<String, String>> reservations = [
    {
      'title': 'Concert',
      'date': '10 November',
      'time': '6:00 pm',
      'imagePath': 'assets/concert.png',
    },
    {
      'title': 'Theater Play',
      'date': '15 October',
      'time': '4:00 pm',
      'imagePath': 'assets/theater.png',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to delete a reservation
  void _deleteReservation(int index) {
    setState(() {
      reservations.removeAt(index);
    });
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to cancel this reservation?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteReservation(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Reservations',
        userId: widget.userId,
        userRole: widget.userRole,
        userPhotoUrl: widget.userPhotoUrl, // Pass the userPhotoUrl here
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          return _buildReservationTile(
            context,
            reservations[index]['title']!,
            reservations[index]['date']!,
            reservations[index]['time']!,
            reservations[index]['imagePath']!,
            index,
          );
        },
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

  Widget _buildReservationTile(
      BuildContext context, String title, String date, String time, String imagePath, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        date,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Cancel') {
                  _showDeleteConfirmationDialog(index); // Show confirmation dialog
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Cancel'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}