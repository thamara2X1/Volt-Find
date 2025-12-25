import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class StationDetailsScreen extends StatefulWidget {
  const StationDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _stationId;

  // Mock station data (in real app, fetch from Firebase using stationId)
  final ChargingStation _station = ChargingStation(
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
    amenities: ['WiFi', 'Cafe', 'Restroom', 'Parking', 'ATM'],
    totalReviews: 124,
    operatingHours: '24/7',
    phoneNumber: '+94 77 123 4567',
    description:
        'High-speed charging station with modern amenities. Located conveniently on the main road with easy access.',
    photos: [
      'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=Station+Photo+1',
      'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Station+Photo+2',
      'https://via.placeholder.com/400x300/FF9800/FFFFFF?text=Station+Photo+3',
    ],
  );

  // Mock reviews data
  final List<Review> _reviews = [
    Review(
      id: '1',
      userName: 'John Doe',
      userAvatar: 'JD',
      rating: 5.0,
      comment:
          'Excellent charging station! Fast charging and great amenities. The cafe is a nice touch.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      helpful: 12,
    ),
    Review(
      id: '2',
      userName: 'Sarah Smith',
      userAvatar: 'SS',
      rating: 4.0,
      comment:
          'Good location and clean facilities. Sometimes gets crowded during peak hours.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      helpful: 8,
    ),
    Review(
      id: '3',
      userName: 'Mike Johnson',
      userAvatar: 'MJ',
      rating: 5.0,
      comment:
          'Best charging station in the area! Staff is helpful and the charging speed is amazing.',
      date: DateTime.now().subtract(const Duration(days: 7)),
      helpful: 15,
    ),
    Review(
      id: '4',
      userName: 'Emma Wilson',
      userAvatar: 'EW',
      rating: 4.0,
      comment: 'Good facilities but pricing could be better. Overall satisfied with the service.',
      date: DateTime.now().subtract(const Duration(days: 10)),
      helpful: 6,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get station ID from route arguments
    _stationId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToBooking() {
    Navigator.pushNamed(context, '/book-now', arguments: _station.id);
  }

  void _navigateToMap() {
    Navigator.pushNamed(context, '/view-map');
  }

  void _makePhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${_station.phoneNumber}...'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _shareStation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing station...')),
    );
  }

  void _addToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.green.shade600,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Station Image
                  Image.network(
                    _station.photos.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green.shade600,
                        child: const Icon(
                          Icons.ev_station,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: _addToFavorites,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareStation,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Station Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _station.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _station.isAvailable
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _station.isAvailable ? 'Available' : 'Full',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _station.isAvailable
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rating and Reviews
                      Row(
                        children: [
                          Icon(Icons.star, size: 20, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${_station.rating}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_station.totalReviews} reviews)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${_station.distance.toStringAsFixed(1)} km away',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Address
                      Row(
                        children: [
                          Icon(Icons.place, size: 18, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _station.address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Quick Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(
                        icon: Icons.navigation,
                        label: 'Navigate',
                        onTap: _navigateToMap,
                      ),
                      _buildQuickAction(
                        icon: Icons.phone,
                        label: 'Call',
                        onTap: _makePhoneCall,
                      ),
                      _buildQuickAction(
                        icon: Icons.share_location,
                        label: 'Share',
                        onTap: _shareStation,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.green.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: Colors.green.shade600,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Reviews'),
                      Tab(text: 'Photos'),
                    ],
                  ),
                ),

                // Tab Content
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildReviewsTab(),
                      _buildPhotosTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Bar with Book Button
      bottomNavigationBar: _station.isAvailable
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.green.shade700,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _station.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Availability
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.ev_station, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Available Slots: ${_station.availableSlots}/${_station.totalSlots}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Operating Hours: ${_station.operatingHours}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pricing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pricing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.payments, color: Colors.grey.shade700),
                    const SizedBox(width: 12),
                    Text(
                      'Rs. ${_station.pricePerKwh.toStringAsFixed(0)}/kWh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Connector Types
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connector Types',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _station.connectorTypes
                      .map((type) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Amenities
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: _station.amenities
                      .map((amenity) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getAmenityIcon(amenity),
                                size: 20,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(amenity, style: const TextStyle(fontSize: 14)),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Rating
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      _station.rating.toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < _station.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_station.totalReviews} reviews',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, 78),
                      _buildRatingBar(4, 42),
                      _buildRatingBar(3, 18),
                      _buildRatingBar(2, 8),
                      _buildRatingBar(1, 2),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Write Review Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Show write review dialog
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
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

          const SizedBox(height: 24),

          // Reviews List
          ..._reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.amber.shade600),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade600,
                child: Text(
                  review.userAvatar,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text('Helpful (${review.helpful})'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _station.photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _station.photos[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 50),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'cafe':
        return Icons.local_cafe;
      case 'restroom':
        return Icons.wc;
      case 'parking':
        return Icons.local_parking;
      case 'atm':
        return Icons.atm;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${(difference / 30).floor()} months ago';
  }
}

// Models
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
  final String operatingHours;
  final String phoneNumber;
  final String description;
  final List<String> photos;

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
    required this.amenities,
    required this.totalReviews,
    required this.operatingHours,
    required this.phoneNumber,
    required this.description,
    required this.photos,
  });
}

class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final int helpful;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.helpful,
  });
}