import 'package:flutter/material.dart';

class FiltersPage extends StatefulWidget {
  final List<dynamic> events;

  const FiltersPage({super.key, required this.events});

  @override
  _FiltersPageState createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  double _priceValue = 0;
  String _selectedLocation = '';
  String _selectedTag = '';
  DateTime? _selectedDate;
  List<dynamic> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _filteredEvents = widget.events;
  }

  void _applyFilters() {
    setState(() {
      _filteredEvents = widget.events.where((event) {
        bool matchesPrice = event['tickets'].any((ticket) => ticket['price'] <= _priceValue);
        bool matchesLocation = _selectedLocation.isEmpty || event['location'] == _selectedLocation;
        bool matchesTag = _selectedTag.isEmpty || event['tags'].contains(_selectedTag);
        bool matchesDate = _selectedDate == null || event['fechas_eventos'].any((date) {
          DateTime eventDate = DateTime.parse(date);
          return eventDate.year == _selectedDate!.year &&
              eventDate.month == _selectedDate!.month &&
              eventDate.day == _selectedDate!.day;
        });
        return matchesPrice && matchesLocation && matchesTag && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, _filteredEvents);
          },
        ),
        title: const Text(
          'Filtros',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/user_profile.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Ubicación'),
            _buildLocationFilter(),

            _buildSectionTitle('Fecha'),
            _buildDateFilter(),

            _buildSectionTitle('Tags'),
            _buildTagFilter(),

            _buildSectionTitle('Precio'),
            _buildPriceSlider(),

            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return _buildCard(
      child: DropdownButton<String>(
        value: _selectedLocation.isEmpty ? null : _selectedLocation,
        hint: const Text('Seleccionar ubicación'),
        items: widget.events.map<DropdownMenuItem<String>>((event) {
          return DropdownMenuItem<String>(
            value: event['location'],
            child: Text(event['location']),
          );
        }).toSet().toList(),
        onChanged: (value) {
          setState(() {
            _selectedLocation = value ?? '';
          });
        },
      ),
    );
  }

  Widget _buildDateFilter() {
    return _buildCard(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
            child: const Text('Seleccionar fecha'),
          ),
          if (_selectedDate != null)
            Text('Fecha seleccionada: ${_selectedDate!.toLocal()}'.split(' ')[0]),
        ],
      ),
    );
  }

  Widget _buildTagFilter() {
    return _buildCard(
      child: DropdownButton<String>(
        value: _selectedTag.isEmpty ? null : _selectedTag,
        hint: const Text('Seleccionar tag'),
        items: widget.events.expand((event) => event['tags']).toSet().map<DropdownMenuItem<String>>((tag) {
          return DropdownMenuItem<String>(
            value: tag,
            child: Text(tag),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedTag = value ?? '';
          });
        },
      ),
    );
  }

  Widget _buildPriceSlider() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Precio',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Free', style: TextStyle(color: Colors.black54)),
              Expanded(
                child: Slider(
                  value: _priceValue,
                  min: 0,
                  max: 400,
                  divisions: 10,
                  activeColor: Colors.blue.shade600,
                  inactiveColor: Colors.blue.shade100,
                  onChanged: (value) {
                    setState(() {
                      _priceValue = value;
                    });
                  },
                ),
              ),
              Text(
                '${_priceValue.round()}',
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _priceValue = 0;
                _selectedLocation = '';
                _selectedTag = '';
                _selectedDate = null;
                _filteredEvents = widget.events;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Borrar'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context, _filteredEvents);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(150, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}