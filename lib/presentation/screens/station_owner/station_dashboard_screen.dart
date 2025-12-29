import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the migration service
// import 'package:volt_find/services/station_data_migration_service.dart';

/// Temporary inline version - move to services folder
class StationDataMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkAndMigrateStationData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final stationsQuery = await _firestore
          .collection('stations')
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      if (stationsQuery.docs.isEmpty) return false;

      bool migrationPerformed = false;

      for (var stationDoc in stationsQuery.docs) {
        final data = stationDoc.data();
        final stationId = stationDoc.id;
        
        if (_needsMigration(data)) {
          print('🔧 Auto-migrating station: $stationId');
          await _migrateStation(stationId, data);
          migrationPerformed = true;
        }
      }

      return migrationPerformed;
    } catch (e) {
      print('❌ Migration error: $e');
      return false;
    }
  }

  bool _needsMigration(Map<String, dynamic> data) {
    final totalSlots = data['totalSlots'] ?? 0;
    final pricePerKwh = data['pricePerKwh'] ?? 0.0;
    return totalSlots == 0 || pricePerKwh == 0.0;
  }

  Future<void> _migrateStation(String stationId, Map<String, dynamic> currentData) async {
    Map<String, dynamic> updates = {};

    if (currentData['totalSlots'] == null || currentData['totalSlots'] == 0) {
      updates['totalSlots'] = 10;
      updates['availableSlots'] = 10;
    }

    if (currentData['pricePerKwh'] == null || currentData['pricePerKwh'] == 0.0) {
      updates['pricePerKwh'] = 45.0;
    }

    if (currentData['rating'] == null || currentData['rating'] == 0.0) {
      updates['rating'] = 4.0;
    }

    if (!currentData.containsKey('isOperational')) {
      updates['isOperational'] = true;
    }

    if (!currentData.containsKey('connectorTypes') || 
        (currentData['connectorTypes'] as List?)?.isEmpty == true) {
      updates['connectorTypes'] = ['Type 2', 'CCS'];
    }

    if (!currentData.containsKey('amenities') || 
        (currentData['amenities'] as List?)?.isEmpty == true) {
      updates['amenities'] = ['Parking', 'WiFi'];
    }

    updates['lastUpdated'] = FieldValue.serverTimestamp();
    updates['migratedAt'] = FieldValue.serverTimestamp();

    if (updates.isNotEmpty) {
      await _firestore.collection('stations').doc(stationId).update(updates);
      print('✅ Auto-migration complete: ${updates.length} fields updated');
    }
  }
}

class StationDashboardScreen extends StatefulWidget {
  const StationDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StationDashboardScreen> createState() => _StationDashboardScreenState();
}

class _StationDashboardScreenState extends State<StationDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StationDataMigrationService _migrationService = StationDataMigrationService();

  User? _currentUser;
  String? _stationId;
  bool _isLoading = true;
  bool _migrationPerformed = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    // Step 1: Run auto-migration
    print('🔄 Running auto-migration check...');
    final migrated = await _migrationService.checkAndMigrateStationData();
    
    if (migrated) {
      print('✅ Auto-migration completed!');
      setState(() {
        _migrationPerformed = true;
      });
      
      // Show notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Station data automatically configured with default values'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Edit',
              textColor: Colors.white,
              onPressed: () {
                _navigateToEditStation();
              },
            ),
          ),
        );
      }
    }

    // Step 2: Load station data
    await _loadStationData();
  }

  Future<void> _loadStationData() async {
    try {
      final stationsQuery = await _firestore
          .collection('stations')
          .where('ownerId', isEqualTo: _currentUser?.uid)
          .limit(1)
          .get();

      if (stationsQuery.docs.isNotEmpty) {
        setState(() {
          _stationId = stationsQuery.docs.first.id;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading station data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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

  void _navigateToEditStation() {
    if (_stationId != null) {
      Navigator.pushNamed(
        context,
        '/edit-station',
        arguments: _stationId,
      );
    }
  }

  void _navigateToUpdateAvailability() {
    if (_stationId != null) {
      Navigator.pushNamed(
        context,
        '/update-availability',
        arguments: _stationId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green.shade600),
              SizedBox(height: 16),
              Text('Initializing dashboard...'),
            ],
          ),
        ),
      );
    }

    if (_stationId == null) {
      return _buildNoStationView();
    }

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
                  Icon(Icons.ev_station, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Station Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                if (_migrationPerformed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_fix_high, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Auto-configured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
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

            // Main Content with Real-time Updates
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('stations')
                    .doc(_stationId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.green.shade600),
                    );
                  }

                  final stationData =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  if (stationData == null) {
                    return const Center(
                      child: Text('Station data not found'),
                    );
                  }

                  return _buildDashboardContent(stationData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStationView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Dashboard'),
        backgroundColor: Colors.green.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.ev_station_outlined,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Station Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You haven\'t set up your charging station yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(Map<String, dynamic> stationData) {
    final name = stationData['businessName'] ?? stationData['name'] ?? 'My Station';
    final address = stationData['address'] ?? 'No address';
    final availableSlots = stationData['availableSlots'] ?? 0;
    final totalSlots = stationData['totalSlots'] ?? 0;
    final pricePerKwh = stationData['pricePerKwh'] ?? 0.0;
    final rating = (stationData['rating'] ?? 0.0).toDouble();
    final isOperational = stationData['isOperational'] ?? false;
    final verified = stationData['verified'] ?? false;
    final wasMigrated = stationData.containsKey('migratedAt');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
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
                  _currentUser?.displayName ?? 'Station Owner',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Station Status Card
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isOperational
                                  ? Colors.green.shade50
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isOperational ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOperational
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (wasMigrated) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.auto_fix_high,
                                  color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Station configured with default values. You can customize them anytime.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!verified) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your station is pending verification',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Quick Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.ev_station,
                      title: 'Available',
                      value: '$availableSlots/$totalSlots',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.star,
                      title: 'Rating',
                      value: rating.toStringAsFixed(1),
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.payments,
                      title: 'Price',
                      value: 'Rs. ${pricePerKwh.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.visibility,
                      title: 'Visibility',
                      value: verified ? 'Public' : 'Hidden',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
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
              _buildActionButton(
                icon: Icons.edit_location_outlined,
                title: 'Update Availability',
                subtitle: 'Change available charging slots',
                onTap: _navigateToUpdateAvailability,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.edit_outlined,
                title: 'Edit Station Details',
                subtitle: 'Update station information',
                onTap: _navigateToEditStation,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.analytics_outlined,
                title: 'View Analytics',
                subtitle: 'See usage statistics',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics - Coming Soon')),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.green.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}