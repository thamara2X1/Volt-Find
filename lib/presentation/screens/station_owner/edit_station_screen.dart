import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStationScreen extends StatefulWidget {
  const EditStationScreen({Key? key}) : super(key: key);

  @override
  State<EditStationScreen> createState() => _EditStationScreenState();
}

class _EditStationScreenState extends State<EditStationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalSlotsController = TextEditingController();
  final _priceController = TextEditingController();

  String? _stationId;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isOperational = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stationId == null) {
      _stationId = ModalRoute.of(context)?.settings.arguments as String?;
      if (_stationId != null) {
        _loadStationData();
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _totalSlotsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadStationData() async {
    try {
      final stationDoc =
          await _firestore.collection('stations').doc(_stationId).get();

      if (stationDoc.exists) {
        final data = stationDoc.data() as Map<String, dynamic>;
        setState(() {
          _businessNameController.text =
              data['businessName'] ?? data['name'] ?? '';
          _addressController.text = data['address'] ?? '';
          _totalSlotsController.text = (data['totalSlots'] ?? 0).toString();
          _priceController.text = (data['pricePerKwh'] ?? 0).toString();
          _isOperational = data['isOperational'] ?? false;
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

  Future<void> _updateStation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final currentDoc =
          await _firestore.collection('stations').doc(_stationId).get();
      final currentData = currentDoc.data() as Map<String, dynamic>;
      final currentAvailable = currentData['availableSlots'] ?? 0;
      final newTotalSlots = int.parse(_totalSlotsController.text);

      // Adjust available slots if total slots changed
      int newAvailableSlots = currentAvailable;
      if (newTotalSlots < currentAvailable) {
        newAvailableSlots = newTotalSlots;
      }

      // Update station data
      await _firestore.collection('stations').doc(_stationId).update({
        'businessName': _businessNameController.text.trim(),
        'name': _businessNameController.text.trim(),
        'address': _addressController.text.trim(),
        'totalSlots': newTotalSlots,
        'availableSlots': newAvailableSlots,
        'pricePerKwh': double.parse(_priceController.text),
        'isOperational': _isOperational,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Station updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error updating station: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
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
          title: const Text('Edit Station'),
          backgroundColor: Colors.green.shade600,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Station Details'),
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
                // Business Name
                Text(
                  'Station Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter station name',
                    prefixIcon: Icon(
                      Icons.business,
                      color: Colors.green.shade600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Address
                Text(
                  'Station Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter station address',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Colors.green.shade600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Total Slots
                Text(
                  'Total Charging Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _totalSlotsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter total slots',
                    prefixIcon: Icon(
                      Icons.ev_station,
                      color: Colors.green.shade600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total slots';
                    }
                    final slots = int.tryParse(value);
                    if (slots == null || slots <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Price per kWh
                Text(
                  'Price per kWh (Rs.)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter price per kWh',
                    prefixIcon: Icon(
                      Icons.payments,
                      color: Colors.green.shade600,
                    ),
                    suffixText: 'Rs.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Operational Status Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.power_settings_new,
                        color: _isOperational
                            ? Colors.green.shade600
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Station Operational',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isOperational
                                  ? 'Visible to customers'
                                  : 'Hidden from customers',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isOperational,
                        onChanged: (value) {
                          setState(() {
                            _isOperational = value;
                          });
                        },
                        activeColor: Colors.green.shade600,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changes will be visible to customers immediately. Make sure all information is accurate.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
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
                    onPressed: _isUpdating ? null : _updateStation,
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
                            'Save Changes',
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
}