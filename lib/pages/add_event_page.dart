import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../services/api_service.dart';

class AddEventPage extends StatefulWidget {
  final String userId;
  final String userRole;

  const AddEventPage({super.key, required this.userId, required this.userRole});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedIndex = 2;
  List<String> _categories = ["Ciencia", "Feria", "Exposición", "Educación"]; // Example categories
  final ApiService _apiService = ApiService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation to other pages if necessary
  }

  void _pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  void _pickEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  void _pickStartTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _startDate = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _pickEndTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _endDate = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select start and end dates.')),
        );
        return;
      }

      final eventData = {
        "name": _titleController.text,
        "description": _descriptionController.text,
        "photo": _urlController.text,
        "location": _locationController.text,
        "tags": _selectedCategory != null ? [_selectedCategory!] : [],
        "fechas_eventos": [
          dateFormat.format(_startDate!),
          dateFormat.format(_endDate!)
        ],
        "tickets": [
          { "name": "General Admission", "color": "Green", "quantity": 200, "price": 15.00 },
          { "name": "VIP Lab Access", "color": "Red", "quantity": 30, "price": 60.00 }
        ],
        "businessId": int.parse(widget.userId)
      };

      final response = await _apiService.createActivity(eventData);

      if (response['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Eventra', userId: widget.userId, userRole: widget.userRole),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Action to upload an image
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 40),
                            Text(
                              'Upload a picture/poster/banner',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '724x340px and no more than 2Mb recommended',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickStartDate,
                        child: Text(
                          _startDate == null
                              ? 'Select Start Date'
                              : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickStartTime,
                        child: Text(
                          _startDate == null
                              ? 'Select Start Time'
                              : 'Start Time: ${DateFormat('HH:mm').format(_startDate!)}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickEndDate,
                        child: Text(
                          _endDate == null
                              ? 'Select End Date'
                              : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pickEndTime,
                        child: Text(
                          _endDate == null
                              ? 'Select End Time'
                              : 'End Time: ${DateFormat('HH:mm').format(_endDate!)}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Create Event'),
                ),
              ],
            ),
          ),
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
}