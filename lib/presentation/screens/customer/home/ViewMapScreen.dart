import 'package:flutter/material.dart';

class ViewMapScreen extends StatefulWidget {
  const ViewMapScreen({Key? key}) : super(key: key);

  @override
  State<ViewMapScreen> createState() => _ViewMapScreenState();
}

class _ViewMapScreenState extends State<ViewMapScreen> {
  String? _selectedStationId;
  
  // Charging stations data (mock data)
  final List<ChargingStation> _stations = [
    ChargingStation(
      id: '1',
      name: 'Tesla Supercharger Station',
      address: 'Kalutara Main Road',
      distance: '0.8 km',
      availableSlots: 8,
      totalSlots: 12,
      price: 'Rs. 45/kWh',
      rating: 4.5,
      connectorTypes: ['Type 2', 'CCS'],
      isAvailable: true,
    ),
    ChargingStation(
      id: '2',
      name: 'EV Power Hub',
      address: 'Galle Road, Panadura',
      distance: '1.2 km',
      availableSlots: 3,
      totalSlots: 6,
      price: 'Rs. 40/kWh',
      rating: 4.2,
      connectorTypes: ['Type 2', 'CHAdeMO'],
      isAvailable: true,
    ),
    ChargingStation(
      id: '3',
      name: 'City Charge Station',
      address: 'Colombo Road',
      distance: '1.8 km',
      availableSlots: 1,
      totalSlots: 8,
      price: 'Rs. 50/kWh',
      rating: 4.7,
      connectorTypes: ['Type 2', 'CCS', 'CHAdeMO'],
      isAvailable: true,
    ),
    ChargingStation(
      id: '4',
      name: 'Mall Parking Charger',
      address: 'Liberty Plaza, Colombo',
      distance: '2.3 km',
      availableSlots: 0,
      totalSlots: 10,
      price: 'Rs. 55/kWh',
      rating: 4.0,
      connectorTypes: ['Type 2'],
      isAvailable: false,
    ),
  ];

  void _showStationDetails(ChargingStation station) {
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
            const SizedBox(height: 12),

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
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigation to ${station.name}'),
                        ),
                      );
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking ${station.name}'),
                        ),
                      );
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Nearby Stations'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Placeholder
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Stack(
              children: [
                // Map Background Pattern
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 80,
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Map View',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Google Maps integration coming soon',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Station count badge
                Positioned(
                  bottom: 16,
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
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search charging stations...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Stations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final station = _stations[index];
                return _buildStationCard(station);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(ChargingStation station) {
    return GestureDetector(
      onTap: () => _showStationDetails(station),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        station.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  station.distance,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.ev_station, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${station.availableSlots}/${station.totalSlots}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(
                  station.rating.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payments, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  station.price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Charging Station Model
class ChargingStation {
  final String id;
  final String name;
  final String address;
  final String distance;
  final int availableSlots;
  final int totalSlots;
  final String price;
  final double rating;
  final List<String> connectorTypes;
  final bool isAvailable;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.availableSlots,
    required this.totalSlots,
    required this.price,
    required this.rating,
    required this.connectorTypes,
    required this.isAvailable,
  });
}