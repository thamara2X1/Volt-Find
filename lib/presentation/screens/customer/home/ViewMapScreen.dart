import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:volt_find/widgets/custom_bottom_nav_bar.dart';

class ViewMapScreen extends StatefulWidget {
  const ViewMapScreen({Key? key}) : super(key: key);

  @override
  State<ViewMapScreen> createState() => _ViewMapScreenState();
}

class _ViewMapScreenState extends State<ViewMapScreen> {
  final MapController _mapController = MapController();
  String? _selectedStationId;
  
  // Current user location (Kalutara, Sri Lanka)
  final LatLng _currentPosition = const LatLng(6.5854, 79.9607);
  
  // Charging stations data
  final List<ChargingStation> _stations = [
    ChargingStation(
      id: '1',
      name: 'Tesla Supercharger Station',
      position: const LatLng(6.5854, 79.9607),
      address: 'Kalutara Main Road, Kalutara',
      distance: '0.8 km',
      availableSlots: 8,
      totalSlots: 12,
      price: 'Rs. 45/kWh',
      rating: 4.5,
      connectorTypes: ['Type 2', 'CCS'],
      isAvailable: true,
      amenities: ['WiFi', 'Cafe', 'Restroom'],
    ),
    ChargingStation(
      id: '2',
      name: 'EV Power Hub',
      position: const LatLng(6.5900, 79.9650),
      address: 'Galle Road, Panadura',
      distance: '1.2 km',
      availableSlots: 3,
      totalSlots: 6,
      price: 'Rs. 40/kWh',
      rating: 4.2,
      connectorTypes: ['Type 2', 'CHAdeMO'],
      isAvailable: true,
      amenities: ['WiFi', 'Parking'],
    ),
    ChargingStation(
      id: '3',
      name: 'City Charge Station',
      position: const LatLng(6.5800, 79.9550),
      address: 'Colombo Road, Kalutara',
      distance: '1.8 km',
      availableSlots: 1,
      totalSlots: 8,
      price: 'Rs. 50/kWh',
      rating: 4.7,
      connectorTypes: ['Type 2', 'CCS', 'CHAdeMO'],
      isAvailable: true,
      amenities: ['WiFi', 'Cafe', 'Restroom', 'Shopping'],
    ),
    ChargingStation(
      id: '4',
      name: 'Mall Parking Charger',
      position: const LatLng(6.5750, 79.9700),
      address: 'Liberty Plaza, Colombo',
      distance: '2.3 km',
      availableSlots: 0,
      totalSlots: 10,
      price: 'Rs. 55/kWh',
      rating: 4.0,
      connectorTypes: ['Type 2'],
      isAvailable: false,
      amenities: ['Parking', 'Shopping', 'Food Court'],
    ),
  ];

  void _showStationDetails(ChargingStation station) {
    setState(() {
      _selectedStationId = station.id;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildStationBottomSheet(station),
    );
  }

  Widget _buildStationBottomSheet(ChargingStation station) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Station Name and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: station.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      station.isAvailable ? 'Available' : 'Full',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: station.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rating and Distance
              Row(
                children: [
                  Icon(Icons.star, size: 20, color: Colors.amber.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${station.rating}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    station.distance,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      station.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 16),

              // Availability
              Row(
                children: [
                  Icon(Icons.ev_station, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Available Slots: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${station.availableSlots}/${station.totalSlots}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price
              Row(
                children: [
                  Icon(Icons.payments, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Price: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    station.price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Connector Types
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.power, size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Connectors: ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: station.connectorTypes.map((type) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amenities
              if (station.amenities.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_cafe, size: 20, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Amenities: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: station.amenities.map((amenity) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              amenity,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              const Divider(),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToStation(station);
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Navigate'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.green.shade600),
                        foregroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: station.isAvailable ? () {
                        Navigator.pop(context);
                        _bookStation(station);
                      } : null,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStation(ChargingStation station) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${station.name}...'),
        backgroundColor: Colors.green.shade600,
      ),
    );
    // TODO: Implement navigation
  }

  void _bookStation(ChargingStation station) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${station.name}...'),
        backgroundColor: Colors.green.shade600,
      ),
    );
    // TODO: Navigate to booking screen
  }

  void _goToCurrentLocation() {
    _mapController.move(_currentPosition, 14.0);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Stations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Available Only'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.green.shade600,
            ),
            CheckboxListTile(
              title: const Text('Type 2 Connector'),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.green.shade600,
            ),
            CheckboxListTile(
              title: const Text('CCS Connector'),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.green.shade600,
            ),
            CheckboxListTile(
              title: const Text('CHAdeMO Connector'),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.green.shade600,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters applied')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    // Navigate to Home screen, replacing current route
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // Map Tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.voltfind',
                maxZoom: 19,
              ),
              
              // Current Location Marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Station Markers
              MarkerLayer(
                markers: _stations.map((station) {
                  return Marker(
                    point: station.position,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showStationDetails(station),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: station.isAvailable 
                                ? Colors.green.shade600 
                                : Colors.red.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.ev_station,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Search Bar
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _navigateToHome, // Navigate to Home
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/search');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Search charging stations...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Buttons
          Positioned(
            right: 16,
            bottom: 180, // Adjusted for bottom nav bar
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'current_location',
                  onPressed: _goToCurrentLocation,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.my_location, color: Colors.green.shade600),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'list_view',
                  onPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                  backgroundColor: Colors.green.shade600,
                  child: const Icon(Icons.list, color: Colors.white),
                ),
              ],
            ),
          ),

          // Station Count Badge
          Positioned(
            bottom: 100, // Adjusted for bottom nav bar
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ev_station, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_stations.length} stations nearby',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Add custom bottom navigation bar
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1), // Map is index 1
    );
  }
}

// Charging Station Model
class ChargingStation {
  final String id;
  final String name;
  final LatLng position;
  final String address;
  final String distance;
  final int availableSlots;
  final int totalSlots;
  final String price;
  final double rating;
  final List<String> connectorTypes;
  final bool isAvailable;
  final List<String> amenities;

  ChargingStation({
    required this.id,
    required this.name,
    required this.position,
    required this.address,
    required this.distance,
    required this.availableSlots,
    required this.totalSlots,
    required this.price,
    required this.rating,
    required this.connectorTypes,
    required this.isAvailable,
    this.amenities = const [],
  });
}