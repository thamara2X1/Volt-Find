import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to automatically detect and fix incomplete station data
/// This runs automatically when station owner logs in
class StationDataMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check and migrate station data automatically
  /// Returns true if migration was performed
  Future<bool> checkAndMigrateStationData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        return false;
      }

      print('🔍 Checking station data for user: ${currentUser.uid}');

      // Find all stations owned by this user
      final stationsQuery = await _firestore
          .collection('stations')
          .where('ownerId', isEqualTo: currentUser.uid)
          .get();

      if (stationsQuery.docs.isEmpty) {
        print('ℹ️ No stations found for this owner');
        return false;
      }

      bool migrationPerformed = false;

      for (var stationDoc in stationsQuery.docs) {
        final data = stationDoc.data();
        final stationId = stationDoc.id;
        
        print('📊 Checking station: $stationId');
        
        // Check if station needs migration
        if (_needsMigration(data)) {
          print('🔧 Station needs migration, updating...');
          await _migrateStation(stationId, data);
          migrationPerformed = true;
          print('✅ Station migrated successfully');
        } else {
          print('✓ Station data is complete');
        }
      }

      return migrationPerformed;
    } catch (e) {
      print('❌ Error checking station data: $e');
      return false;
    }
  }

  /// Check if station data needs migration
  bool _needsMigration(Map<String, dynamic> data) {
    // Check for missing or invalid fields
    final totalSlots = data['totalSlots'] ?? 0;
    final availableSlots = data['availableSlots'] ?? 0;
    final pricePerKwh = data['pricePerKwh'] ?? 0.0;
    
    // Check if critical fields are missing or zero
    if (totalSlots == 0 || pricePerKwh == 0.0) {
      print('❌ Missing critical fields: totalSlots=$totalSlots, pricePerKwh=$pricePerKwh');
      return true;
    }

    // Check if required fields exist
    final requiredFields = [
      'totalSlots',
      'availableSlots',
      'pricePerKwh',
      'rating',
      'isOperational',
      'connectorTypes',
      'amenities',
    ];

    for (var field in requiredFields) {
      if (!data.containsKey(field)) {
        print('❌ Missing field: $field');
        return true;
      }
    }

    return false;
  }

  /// Migrate station with default values
  Future<void> _migrateStation(String stationId, Map<String, dynamic> currentData) async {
    // Prepare update data with defaults
    Map<String, dynamic> updates = {};

    // Fix totalSlots
    if (currentData['totalSlots'] == null || currentData['totalSlots'] == 0) {
      updates['totalSlots'] = 10; // Default: 10 slots
      print('  → Setting totalSlots to 10');
    }

    // Fix availableSlots
    final totalSlots = updates['totalSlots'] ?? currentData['totalSlots'] ?? 10;
    if (currentData['availableSlots'] == null || currentData['availableSlots'] == 0) {
      updates['availableSlots'] = totalSlots; // All slots available by default
      print('  → Setting availableSlots to $totalSlots');
    }

    // Fix pricePerKwh
    if (currentData['pricePerKwh'] == null || currentData['pricePerKwh'] == 0.0) {
      updates['pricePerKwh'] = 45.0; // Default price
      print('  → Setting pricePerKwh to 45.0');
    }

    // Fix rating
    if (currentData['rating'] == null || currentData['rating'] == 0.0) {
      updates['rating'] = 4.0; // Default rating
      print('  → Setting rating to 4.0');
    }

    // Fix isOperational
    if (!currentData.containsKey('isOperational')) {
      updates['isOperational'] = false; // Default: not operational until owner activates
      print('  → Setting isOperational to false');
    }

    // Fix connectorTypes
    if (!currentData.containsKey('connectorTypes') || 
        (currentData['connectorTypes'] as List?)?.isEmpty == true) {
      updates['connectorTypes'] = ['Type 2', 'CCS']; // Default connectors
      print('  → Setting default connectorTypes');
    }

    // Fix amenities
    if (!currentData.containsKey('amenities') || 
        (currentData['amenities'] as List?)?.isEmpty == true) {
      updates['amenities'] = ['Parking', 'WiFi']; // Default amenities
      print('  → Setting default amenities');
    }

    // Fix description
    if (!currentData.containsKey('description') || 
        currentData['description'] == null ||
        currentData['description'].toString().isEmpty) {
      updates['description'] = 'EV Charging Station';
      print('  → Setting default description');
    }

    // Fix status
    if (currentData['status'] == 'pending_setup' && updates.isNotEmpty) {
      updates['status'] = 'active'; // Change status after migration
      print('  → Changing status from pending_setup to active');
    }

    // Add timestamp
    updates['lastUpdated'] = FieldValue.serverTimestamp();
    updates['migratedAt'] = FieldValue.serverTimestamp();

    // Perform update
    if (updates.isNotEmpty) {
      await _firestore.collection('stations').doc(stationId).update(updates);
      print('✅ Updated ${updates.length} fields');
    }
  }

  /// Get migration summary for display
  Future<Map<String, dynamic>?> getMigrationSummary() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final stationsQuery = await _firestore
          .collection('stations')
          .where('ownerId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (stationsQuery.docs.isEmpty) return null;

      final data = stationsQuery.docs.first.data();
      
      return {
        'needsMigration': _needsMigration(data),
        'totalSlots': data['totalSlots'] ?? 0,
        'availableSlots': data['availableSlots'] ?? 0,
        'pricePerKwh': data['pricePerKwh'] ?? 0.0,
        'isOperational': data['isOperational'] ?? false,
      };
    } catch (e) {
      print('Error getting migration summary: $e');
      return null;
    }
  }
}