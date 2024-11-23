import 'package:eventra_app/pages/add_event_page.dart';
import 'package:flutter/material.dart';
import '../pages/search_page.dart';
import '../pages/reservation_page.dart';
import '../pages/tickets_page.dart';
import '../pages/home_page.dart';
import '../pages/login.dart';
import '../pages/my_events_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userId;
  final String userRole;
  final String userPhotoUrl; // Add this parameter

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userId,
    required this.userRole,
    required this.userPhotoUrl, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = _buildBottomNavigationBarItems();

    // Ensure currentIndex is within the valid range
    final validIndex = currentIndex >= 0 && currentIndex < items.length ? currentIndex : 0;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: items,
      selectedItemColor: const Color(0xFFFFA726),
      unselectedItemColor: Colors.grey,
      currentIndex: validIndex,
      onTap: (index) {
        if ((userRole == 'BUSINESS' && index == 2) || (userRole != 'BUSINESS' && index == 4)) {
          _showBottomSheet(context);
        } else {
          onTap(index);  // Invoca la función onTap con el índice seleccionado
          _navigateToPage(context, index);
        }
      },
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    if (userRole == 'BUSINESS') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ];
    }
  }

  void _navigateToPage(BuildContext context, int index) {
    if (userRole == 'BUSINESS') {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyEventsPage(userId: userId, userRole: userRole, userPhotoUrl: userPhotoUrl)),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage(userId: userId, userRole: userRole, userPhotoUrl: userPhotoUrl)),
          );
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(userId: userId, userRole: userRole, userPhotoUrl: userPhotoUrl)),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SearchPage(userId: userId, userRole: userRole, userPhotoUrl: userPhotoUrl)),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ReservationPage(userId: userId, userRole: userRole, userPhotoUrl: userPhotoUrl)),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TicketsPage(userId: userId, userRole: userRole, userPhotoUrl: userPhotoUrl)),
          );
          break;
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
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
                onTap: () async {
                  // Clear user data (example using SharedPreferences)
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  // Navigate to the login page and remove all previous routes
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
}