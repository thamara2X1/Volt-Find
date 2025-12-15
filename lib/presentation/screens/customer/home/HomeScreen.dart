import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/search');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToViewMap() {
    Navigator.pushNamed(context, '/view-map');
  }

  void _navigateToStationDetails(String stationId) {
    Navigator.pushNamed(context, '/station-details', arguments: stationId);
  }

  void _navigateToEVNews() {
    Navigator.pushNamed(context, '/ev-news');
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await _auth.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.green.shade600,
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.electric_bolt, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'ChargePoint',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {
                    // Handle notifications
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _handleLogout,
                ),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser?.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Search Bar
                          GestureDetector(
                            onTap: _navigateToSearch,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                  Icon(Icons.search, color: Colors.grey.shade600),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Search charging stations...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.map_outlined,
                                title: 'View Map',
                                color: Colors.blue,
                                onTap: _navigateToViewMap,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.person_outline,
                                title: 'Profile',
                                color: Colors.purple,
                                onTap: _navigateToProfile,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.settings_outlined,
                                title: 'Settings',
                                color: Colors.orange,
                                onTap: _navigateToSettings,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionCard(
                                icon: Icons.article_outlined,
                                title: 'EV News',
                                color: Colors.green,
                                onTap: _navigateToEVNews,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Nearby Stations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nearby Stations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSearch,
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Station Cards List
                  _buildStationCard(
                    name: 'Tesla Supercharger Station',
                    distance: '0.8 km',
                    availability: 'Available',
                    availableSlots: 8,
                    totalSlots: 12,
                    price: 'Rs. 45/kWh',
                    rating: 4.5,
                    isAvailable: true,
                  ),

                  _buildStationCard(
                    name: 'EV Power Hub',
                    distance: '1.2 km',
                    availability: 'Available',
                    availableSlots: 3,
                    totalSlots: 6,
                    price: 'Rs. 40/kWh',
                    rating: 4.2,
                    isAvailable: true,
                  ),

                  _buildStationCard(
                    name: 'City Charge Station',
                    distance: '1.8 km',
                    availability: 'Busy',
                    availableSlots: 1,
                    totalSlots: 8,
                    price: 'Rs. 50/kWh',
                    rating: 4.7,
                    isAvailable: true,
                  ),

                  _buildStationCard(
                    name: 'Mall Parking Charger',
                    distance: '2.3 km',
                    availability: 'Full',
                    availableSlots: 0,
                    totalSlots: 10,
                    price: 'Rs. 55/kWh',
                    rating: 4.0,
                    isAvailable: false,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard({
    required String name,
    required String distance,
    required String availability,
    required int availableSlots,
    required int totalSlots,
    required String price,
    required double rating,
    required bool isAvailable,
  }) {
    return GestureDetector(
      onTap: () => _navigateToStationDetails('station_id_123'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    availability,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.ev_station, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        '$availableSlots/$totalSlots Available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payments, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  price,
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