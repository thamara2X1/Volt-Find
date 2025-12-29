import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateAvailabilityScreen extends StatefulWidget {
  const UpdateAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAvailabilityScreen> createState() =>
      _UpdateAvailabilityScreenState();
}

class _UpdateAvailabilityScreenState extends State<UpdateAvailabilityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? _stationId;
  int _availableSlots = 0;
  int _totalSlots = 0;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stationId == null) {
      _stationId = ModalRoute.of(context)?.settings.arguments as String?;
      print('📍 Station ID from arguments: $_stationId');
      if (_stationId != null) {
        _loadStationData();
      } else {
        print('❌ No station ID provided!');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStationData() async {
    print('🔄 Loading station data for ID: $_stationId');
    try {
      final stationDoc =
          await _firestore.collection('stations').doc(_stationId).get();

      if (stationDoc.exists) {
        final data = stationDoc.data() as Map<String, dynamic>;
        print('✅ Station data loaded: $data');
        setState(() {
          _availableSlots = data['availableSlots'] ?? 0;
          _totalSlots = data['totalSlots'] ?? 0;
          _isLoading = false;
        });
        print('📊 Available: $_availableSlots, Total: $_totalSlots');
      } else {
        print('❌ Station document does not exist!');
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Station not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading station data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAvailability() async {
    print('🚀 Starting availability update...');
    print('📍 Station ID: $_stationId');
    print('📊 Updating to: $_availableSlots available out of $_totalSlots total');

    if (_stationId == null) {
      print('❌ Cannot update: Station ID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Station ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    if (_availableSlots > _totalSlots) {
      print('❌ Validation failed: Available ($_availableSlots) > Total ($_totalSlots)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Available slots cannot exceed total slots'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      print('💾 Updating Firestore...');
      
      // First, verify the document exists
      final docSnapshot = await _firestore
          .collection('stations')
          .doc(_stationId)
          .get();
      
      if (!docSnapshot.exists) {
        throw Exception('Station document not found');
      }

      print('✅ Document exists, proceeding with update');

      // Update station availability in Firestore
      await _firestore.collection('stations').doc(_stationId).update({
        'availableSlots': _availableSlots,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore update successful!');
      print('📊 New availability: $_availableSlots/$_totalSlots');

      // Verify the update
      final updatedDoc = await _firestore
          .collection('stations')
          .doc(_stationId)
          .get();
      final updatedData = updatedDoc.data() as Map<String, dynamic>?;
      print('🔍 Verified update - Available slots: ${updatedData?['availableSlots']}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Availability updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a moment then go back
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          print('⬅️ Navigating back to dashboard');
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } on FirebaseException catch (e) {
      print('❌ FirebaseException: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase error: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Unexpected error updating availability: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Update Availability'),
          backgroundColor: Colors.green.shade600,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green.shade600),
              const SizedBox(height: 16),
              const Text('Loading station data...'),
            ],
          ),
        ),
      );
    }

    if (_stationId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Update Availability'),
          backgroundColor: Colors.green.shade600,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Station ID not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Please return to dashboard and try again'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Availability'),
        backgroundColor: Colors.green.shade600,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debug Info (Remove in production)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Station ID: $_stationId',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changes will be visible to customers immediately',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Total Slots (Read-only)
                Text(
                  'Total Charging Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Slots',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _totalSlots.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Available Slots (Editable)
                Text(
                  'Available Charging Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Now',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            _availableSlots.toString(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Decrease Button
                          _buildAdjustButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (_availableSlots > 0) {
                                setState(() {
                                  _availableSlots--;
                                });
                                print('➖ Decreased to: $_availableSlots');
                              }
                            },
                            enabled: _availableSlots > 0,
                          ),

                          // Current Value Display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_availableSlots / $_totalSlots',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),

                          // Increase Button
                          _buildAdjustButton(
                            icon: Icons.add,
                            onTap: () {
                              if (_availableSlots < _totalSlots) {
                                setState(() {
                                  _availableSlots++;
                                });
                                print('➕ Increased to: $_availableSlots');
                              }
                            },
                            enabled: _availableSlots < _totalSlots,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        label: 'All Full',
                        icon: Icons.block,
                        color: Colors.red,
                        onTap: () {
                          setState(() {
                            _availableSlots = 0;
                          });
                          print('🚫 Set to All Full: 0/$_totalSlots');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        label: 'All Available',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onTap: () {
                          setState(() {
                            _availableSlots = _totalSlots;
                          });
                          print('✅ Set to All Available: $_totalSlots/$_totalSlots');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Status Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(),
                        color: _getStatusColor(),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Preview',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUpdating ? null : _updateAvailability,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isUpdating
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Update Availability',
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
        ),
      ),
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: enabled ? Colors.green.shade600 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_availableSlots == 0) {
      return Colors.red;
    } else if (_availableSlots <= _totalSlots * 0.25) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    if (_availableSlots == 0) {
      return Icons.cancel;
    } else if (_availableSlots <= _totalSlots * 0.25) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  String _getStatusText() {
    if (_availableSlots == 0) {
      return 'Full - No slots available';
    } else if (_availableSlots <= _totalSlots * 0.25) {
      return 'Busy - Limited availability';
    } else {
      return 'Available - Open for charging';
    }
  }
}