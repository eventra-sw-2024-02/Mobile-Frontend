import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_page.dart';

class EventRegistrationPage extends StatefulWidget {
  final String eventName;
  final int eventId;

  const EventRegistrationPage({super.key, required this.eventName, required this.eventId});

  @override
  _EventRegistrationPageState createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  double _totalCost = 0.0;
  String? _eventDate;
  String? _eventPhoto;
  int? _clientId;
  int? _ticketId;

  Map<String, double> _ticketPrices = {};
  Map<String, int> _ticketQuantities = {};

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
    _fetchClientId();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/activities/${widget.eventId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _eventDate = data['fechas_eventos'][0];
          _eventPhoto = data['photo'];
          _ticketPrices = {
            for (var ticket in data['tickets'])
              ticket['name']: ticket['price'].toDouble()
          };
        });
      } else {
        throw Exception('Failed to load event details');
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
  }

  Future<void> _fetchTicketId() async {
    try {
      final response = await http.get(Uri.parse('http://gustavo-tenant-eventrabackend-viae0c-b1b3fd-35-239-187-59.traefik.me/api/tickets/event/${widget.eventId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ticketId = data[0]['idTicket'];
        });
      } else {
        throw Exception('Failed to load ticket ID');
      }
    } catch (e) {
      print('Error fetching ticket ID: $e');
    }
  }

  Future<void> _fetchClientId() async {
    final clientId = await getLoggedInUserId();
    setState(() {
      _clientId = clientId;
    });
  }

  Future<int> getLoggedInUserId() async {
    return 1; // Replace with actual client ID
  }

  void _updateTotalCost() {
    setState(() {
      _totalCost = _ticketQuantities.entries.fold(0.0, (sum, entry) {
        return sum + (entry.value * (_ticketPrices[entry.key] ?? 0.0));
      });
    });
  }

  void _incrementTicketQuantity(String ticketType) {
    setState(() {
      _ticketQuantities[ticketType] = (_ticketQuantities[ticketType] ?? 0) + 1;
      _updateTotalCost();
    });
  }

  void _decrementTicketQuantity(String ticketType) {
    setState(() {
      if ((_ticketQuantities[ticketType] ?? 0) > 0) {
        _ticketQuantities[ticketType] = (_ticketQuantities[ticketType] ?? 0) - 1;
        _updateTotalCost();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.eventName),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_eventPhoto != null)
                Image.network(
                  _eventPhoto!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              if (_eventDate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Fecha del evento: $_eventDate',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: _ticketPrices.keys.map((ticketType) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ticketType, style: const TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _decrementTicketQuantity(ticketType),
                            ),
                            Text('${_ticketQuantities[ticketType] ?? 0}', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _incrementTicketQuantity(ticketType),
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Costo total: \$$_totalCost',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _fetchTicketId();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            totalCost: _totalCost,
                            selectedTickets: _ticketQuantities,
                            ticketPrices: _ticketPrices,
                            ticketId: _ticketId!,
                            clientId: _clientId!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Inscribirme',
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
}