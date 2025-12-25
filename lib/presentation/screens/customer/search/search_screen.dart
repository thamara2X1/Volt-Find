import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  bool _showAvailableOnly = false;
  String _selectedConnectorType = 'All';
  String _sortBy = 'Distance'; // Distance, Price, Rating
  
  // All stations data
  final List<ChargingStation> _allStations = [
    ChargingStation(
      id: '1',
      name: 'Tesla Supercharger Station',
      position: const LatLng(6.5854, 79.9607),
      address: 'Kalutara Main Road, Kalutara',
      distance: 0.8,
      availableSlots: 8,
      totalSlots: 12,
      pricePerKwh: 45.0,
      rating: 4.5,
      connectorTypes: ['Type 2', 'CCS'],
      isAvailable: true,
      amenities: ['WiFi', 'Cafe', 'Restroom'],
      totalReviews: 124,
    ),
    ChargingStation(
      id: '2',
      name: 'EV Power Hub',
      position: const LatLng(6.5900, 79.9650),
      address: 'Galle Road, Panadura',
      distance: 1.2,
      availableSlots: 3,
      totalSlots: 6,
      pricePerKwh: 40.0,
      rating: 4.2,
      connectorTypes: ['Type 2', 'CHAdeMO'],
      isAvailable: true,
      amenities: ['WiFi', 'Parking'],
      totalReviews: 89,
    ),
    ChargingStation(
      id: '3',
      name: 'City Charge Station',
      position: const LatLng(6.5800, 79.9550),
      address: 'Colombo Road, Kalutara',
      distance: 1.8,
      availableSlots: 1,
      totalSlots: 8,
      pricePerKwh: 50.0,
      rating: 4.7,
      connectorTypes: ['Type 2', 'CCS', 'CHAdeMO'],
      isAvailable: true,
      amenities: ['WiFi', 'Cafe', 'Restroom', 'Shopping'],
      totalReviews: 203,
    ),
    ChargingStation(
      id: '4',
      name: 'Mall Parking Charger',
      position: const LatLng(6.5750, 79.9700),
      address: 'Liberty Plaza, Colombo',
      distance: 2.3,
      availableSlots: 0,
      totalSlots: 10,
      pricePerKwh: 55.0,
      rating: 4.0,
      connectorTypes: ['Type 2'],
      isAvailable: false,
      amenities: ['Parking', 'Shopping', 'Food Court'],
      totalReviews: 156,
    ),
    ChargingStation(
      id: '5',
      name: 'Quick Charge Point',
      position: const LatLng(6.5820, 79.9580),
      address: 'Hospital Road, Kalutara',
      distance: 1.5,
      availableSlots: 5,
      totalSlots: 6,
      pricePerKwh: 42.0,
      rating: 4.3,
      connectorTypes: ['Type 2', 'CCS'],
      isAvailable: true,
      amenities: ['WiFi', 'Parking'],
      totalReviews: 67,
    ),
    ChargingStation(
      id: '6',
      name: 'Green Energy Station',
      position: const LatLng(6.5780, 79.9620),
      address: 'Beach Road, Kalutara',
      distance: 2.0,
      availableSlots: 10,
      totalSlots: 15,
      pricePerKwh: 38.0,
      rating: 4.6,
      connectorTypes: ['Type 2', 'CCS', 'CHAdeMO'],
      isAvailable: true,
      amenities: ['WiFi', 'Cafe', 'Restroom', 'Parking', 'ATM'],
      totalReviews: 298,
    ),
  ];

  List<ChargingStation> _filteredStations = [];

  @override
  void initState() {
    super.initState();
    _filteredStations = List.from(_allStations);
    _sortStations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAndSortStations() {
    setState(() {
      // Apply search filter
      _filteredStations = _allStations.where((station) {
        final searchLower = _searchController.text.toLowerCase();
        final nameMatch = station.name.toLowerCase().contains(searchLower);
        final addressMatch = station.address.toLowerCase().contains(searchLower);
        return nameMatch || addressMatch;
      }).toList();

      // Apply availability filter
      if (_showAvailableOnly) {
        _filteredStations = _filteredStations.where((station) => station.isAvailable).toList();
      }

      // Apply connector type filter
      if (_selectedConnectorType != 'All') {
        _filteredStations = _filteredStations.where((station) {
          return station.connectorTypes.contains(_selectedConnectorType);
        }).toList();
      }

      // Apply sorting
      _sortStations();
    });
  }

  void _sortStations() {
    switch (_sortBy) {
      case 'Distance':
        _filteredStations.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'Price':
        _filteredStations.sort((a, b) => a.pricePerKwh.compareTo(b.pricePerKwh));
        break;
      case 'Rating':
        _filteredStations.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
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

                // Title
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Availability Filter
                CheckboxListTile(
                  title: const Text('Show Available Only'),
                  value: _showAvailableOnly,
                  onChanged: (value) {
                    setModalState(() {
                      _showAvailableOnly = value ?? false;
                    });
                  },
                  activeColor: Colors.green.shade600,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Connector Type Filter
                const Text(
                  'Connector Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['All', 'Type 2', 'CCS', 'CHAdeMO'].map((type) {
                    final isSelected = _selectedConnectorType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedConnectorType = type;
                        });
                      },
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Sort By
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Distance', 'Price', 'Rating'].map((sort) {
                    final isSelected = _sortBy == sort;
                    return ChoiceChip(
                      label: Text(sort),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _sortBy = sort;
                        });
                      },
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterAndSortStations();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToStationDetails(String stationId) {
    Navigator.pushNamed(context, '/station-details', arguments: stationId);
  }

  void _navigateToMap() {
    Navigator.pushNamed(context, '/view-map');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Search Stations'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _navigateToMap,
            tooltip: 'Map View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterAndSortStations(),
                  decoration: InputDecoration(
                    hintText: 'Search by name or location...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterAndSortStations();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tune, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Filter & Sort'),
                                ],
                              ),
                              onSelected: (selected) => _showFilterBottomSheet(),
                              backgroundColor: Colors.grey.shade200,
                            ),
                            const SizedBox(width: 8),
                            if (_showAvailableOnly)
                              Chip(
                                label: const Text('Available'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _showAvailableOnly = false;
                                    _filterAndSortStations();
                                  });
                                },
                                backgroundColor: Colors.green.shade50,
                              ),
                            if (_selectedConnectorType != 'All') ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(_selectedConnectorType),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _selectedConnectorType = 'All';
                                    _filterAndSortStations();
                                  });
                                },
                                backgroundColor: Colors.blue.shade50,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            color: Colors.grey.shade100,
            child: Text(
              '${_filteredStations.length} stations found • Sorted by $_sortBy',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Stations List
          Expanded(
            child: _filteredStations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStations.length,
                    itemBuilder: (context, index) {
                      final station = _filteredStations[index];
                      return _buildStationCard(station);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No stations found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(ChargingStation station) {
    return GestureDetector(
      onTap: () => _navigateToStationDetails(station.id),
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
            // Header
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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

            // Info Row
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${station.distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.ev_station, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${station.availableSlots}/${station.totalSlots}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(
                  '${station.rating}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' (${station.totalReviews})',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price and Connectors
            Row(
              children: [
                Icon(Icons.payments, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Rs. ${station.pricePerKwh.toStringAsFixed(0)}/kWh',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                ...station.connectorTypes.take(3).map((type) => Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
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
  final LatLng position;
  final String address;
  final double distance;
  final int availableSlots;
  final int totalSlots;
  final double pricePerKwh;
  final double rating;
  final List<String> connectorTypes;
  final bool isAvailable;
  final List<String> amenities;
  final int totalReviews;

  ChargingStation({
    required this.id,
    required this.name,
    required this.position,
    required this.address,
    required this.distance,
    required this.availableSlots,
    required this.totalSlots,
    required this.pricePerKwh,
    required this.rating,
    required this.connectorTypes,
    required this.isAvailable,
    this.amenities = const [],
    required this.totalReviews,
  });
}