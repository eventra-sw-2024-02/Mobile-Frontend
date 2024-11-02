import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'dart:convert';

class EventRegistrationPage extends StatefulWidget {
  final String eventName;
  final int eventId;

  const EventRegistrationPage({super.key, required this.eventName, required this.eventId});

  @override
  _EventRegistrationPageState createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTicketType;
  int? _selectedTicketQuantity = 1;
  String? _phoneNumber;
  String? _dni;
  String? _selectedAdditionalService;
  double _ticketPrice = 0.0;
  double _totalCost = 0.0;
  double _additionalServiceCost = 0.0;

  Map<String, double> _ticketPrices = {};
  final Map<String, double> _additionalServicePrices = {
    'Ninguno': 0.0,
    'Comida y bebida': 20.0,
    'Estacionamiento': 10.0,
    'Transporte': 15.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  void _fetchEventDetails() {
    // Simulate fetching event details from a server
    final eventData = jsonDecode('''
    [
      {
        "id": 1,
        "name": "Concierto Marc Anthony",
        "description": "Concierto de tus artista favorito",
        "photo": "https://portal.andina.pe/EDPfotografia3/Thumbnail/2023/09/22/000997012W.jpg",
        "location": "La Molina",
        "tags": ["Ciencia"],
        "fechas_eventos": ["2024-11-12T02:41:00", "2024-11-29T02:41:00"],
        "tickets": [
          {"name": "General Admission", "color": "Green", "quantity": 200, "price": 15},
          {"name": "VIP Lab Access", "color": "Red", "quantity": 30, "price": 60}
        ],
        "businessId": 1
      },
      {
        "id": 2,
        "name": "Science Fair",
        "description": "Explore science exhibits and experiments.",
        "photo": "https://www.coldelvalle.edu.mx/wp-content/uploads/2023/09/10p.Que_es_una_feria_de_ciencias-min.jpg",
        "location": "Science Center",
        "tags": ["Ciencia"],
        "fechas_eventos": ["2024-11-15T14:29:00", "2024-11-27T14:29:00"],
        "tickets": [
          {"name": "General Admission", "color": "Green", "quantity": 200, "price": 15},
          {"name": "VIP Lab Access", "color": "Red", "quantity": 30, "price": 60}
        ],
        "businessId": 1
      }
    ]
    ''');

    final event = eventData.firstWhere((event) => event['id'] == widget.eventId);
    setState(() {
      _ticketPrices = {
        for (var ticket in event['tickets']) ticket['name']: ticket['price'].toDouble()
      };
    });
  }

  void _updateTotalCost() {
    setState(() {
      _ticketPrice = _ticketPrices[_selectedTicketType] ?? 0.0;
      _additionalServiceCost = _additionalServicePrices[_selectedAdditionalService] ?? 0.0;
      _totalCost = (_ticketPrice * (_selectedTicketQuantity ?? 1)) + _additionalServiceCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Inscripción - ${widget.eventName}',
          style: const TextStyle(color: Colors.black),
        ),
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
              _buildDropdownField(
                label: 'Tipo de entrada',
                items: _ticketPrices.keys.map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                )).toList(),
                value: _selectedTicketType,
                onChanged: (value) {
                  _selectedTicketType = value;
                  _updateTotalCost();
                },
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Cantidad de entradas',
                items: [1, 2, 3, 4, 5].map((quantity) => DropdownMenuItem<int>(
                  value: quantity,
                  child: Text(quantity.toString()),
                )).toList(),
                value: _selectedTicketQuantity,
                onChanged: (value) {
                  _selectedTicketQuantity = value;
                  _updateTotalCost();
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Número de teléfono',
                onChanged: (value) {
                  _phoneNumber = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su número de teléfono';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'DNI',
                onChanged: (value) {
                  _dni = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su DNI';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Servicios adicionales',
                items: _additionalServicePrices.keys.map((service) => DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                )).toList(),
                value: _selectedAdditionalService,
                onChanged: (value) {
                  _selectedAdditionalService = value;
                  _updateTotalCost();
                },
              ),
              const SizedBox(height: 30),
              Text(
                'Costo total: \$$_totalCost',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Inscripción completada'),
                            content: const Text('Te has inscrito en el evento. Para finalizar tu registro, realiza el pago.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Pagar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        totalCost: _totalCost,
                                        ticketType: _selectedTicketType!,
                                        ticketQuantity: _selectedTicketQuantity!,
                                        additionalService: _selectedAdditionalService ?? 'Ninguno',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: const Color(0xFFFFA726), // Naranja
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildTextField({
    required String label,
    required void Function(String) onChanged,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required List<DropdownMenuItem<T>> items,
    required T? value,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
        ),
      ),
      items: items,
      value: value,
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Por favor seleccione una opción';
        }
        return null;
      },
    );
  }
}