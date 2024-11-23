import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final double totalCost;
  final Map<String, int> selectedTickets;
  final Map<String, double> ticketPrices;
  final int ticketId;
  final int clientId;

  const PaymentPage({
    super.key,
    required this.totalCost,
    required this.selectedTickets,
    required this.ticketPrices,
    required this.ticketId,
    required this.clientId,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _paymentFormKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod = "PAGO_EFECTIVO";
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Debugging: Print ticketId and clientId
    print('ticketId: ${widget.ticketId}, clientId: ${widget.clientId}');

    if (widget.ticketId == 0 || widget.clientId == 0) {
      setState(() {
        _errorMessage = 'Invalid ticket or client ID';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://gustavo-tenant-eventrabackend-viae0c-b1b3fd-35-239-187-59.traefik.me/api/tickets/buy'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'idTicket': widget.ticketId,
          'idClient': widget.clientId,
          'methodPayment': _selectedPaymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Pago completado'),
              content: const Text('Gracias por tu inscripción, el pago se ha completado con éxito.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to process payment: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to process payment: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA726)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Formulario de Pago',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _paymentFormKey,
          child: ListView(
            children: <Widget>[
              const Text(
                'Resumen de la inscripción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ...widget.selectedTickets.entries.map((entry) {
                double pricePerTicket = widget.ticketPrices[entry.key] ?? 0.0;
                double totalPrice = entry.value * pricePerTicket;
                return _buildSummaryRow(
                  entry.key,
                  '${entry.value}x',
                  totalPrice.toStringAsFixed(2),
                );
              }).toList(),
              const SizedBox(height: 10),
              _buildTotalRow(widget.totalCost.toStringAsFixed(2)),
              const SizedBox(height: 30),
              _buildPaymentMethodDropdown(),
              const SizedBox(height: 30),
              _buildButtonRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String quantity, String price) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: '$quantity $label',
            readOnly: true,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: TextFormField(
            initialValue: price,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Precio',
              labelStyle: const TextStyle(color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String total) {
    return TextFormField(
      initialValue: total,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Total',
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Elige método de pago',
        labelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['PAGO_EFECTIVO']
          .map((method) => DropdownMenuItem<String>(
        value: method,
        child: Text(method),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione un método de pago';
        }
        return null;
      },
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            minimumSize: const Size(120, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_paymentFormKey.currentState!.validate()) {
              _processPayment();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726),
            minimumSize: const Size(120, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Pagar'),
        ),
      ],
    );
  }
}