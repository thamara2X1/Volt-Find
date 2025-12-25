import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookNowScreen extends StatefulWidget {
  const BookNowScreen({Key? key}) : super(key: key);

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
  String? _stationId;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _selectedDuration = '1 hour';
  String _selectedConnector = 'Type 2';
  bool _isLoading = false;

  // Mock station data (in real app, fetch from Firebase)
  final Map<String, dynamic> _stationData = {
    'id': '1',
    'name': 'Tesla Supercharger Station',
    'address': 'Kalutara Main Road, Kalutara',
    'pricePerKwh': 45.0,
    'connectorTypes': ['Type 2', 'CCS', 'CHAdeMO'],
  };

  // Available time slots
  final List<String> _timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
  ];

  // Duration options
  final List<String> _durations = [
    '30 minutes',
    '1 hour',
    '1.5 hours',
    '2 hours',
    '3 hours',
    '4 hours',
  ];

  // Booked slots (mock data - in real app, fetch from Firebase)
  final List<String> _bookedSlots = ['10:00 AM', '02:00 PM', '05:00 PM'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stationId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade600,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  double _calculateEstimatedCost() {
    final hours = _getDurationInHours();
    final estimatedKwh = hours * 50; // Assume 50 kWh per hour
    return estimatedKwh * _stationData['pricePerKwh'];
  }

  double _getDurationInHours() {
    switch (_selectedDuration) {
      case '30 minutes':
        return 0.5;
      case '1 hour':
        return 1.0;
      case '1.5 hours':
        return 1.5;
      case '2 hours':
        return 2.0;
      case '3 hours':
        return 3.0;
      case '4 hours':
        return 4.0;
      default:
        return 1.0;
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(),
    );

    if (confirmed == true) {
      await _createBooking();
    }
  }

  Widget _buildConfirmationDialog() {
    final estimatedCost = _calculateEstimatedCost();

    return AlertDialog(
      title: const Text('Confirm Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please confirm your booking details:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Station', _stationData['name']),
          _buildInfoRow('Date', _formatDate(_selectedDate)),
          _buildInfoRow('Time', _selectedTimeSlot ?? ''),
          _buildInfoRow('Duration', _selectedDuration),
          _buildInfoRow('Connector', _selectedConnector),
          const Divider(height: 24),
          _buildInfoRow(
            'Estimated Cost',
            'Rs. ${estimatedCost.toStringAsFixed(2)}',
            isHighlight: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBooking() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create booking in Firestore
      final bookingData = {
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'userEmail': user.email,
        'stationId': _stationId,
        'stationName': _stationData['name'],
        'date': Timestamp.fromDate(_selectedDate),
        'timeSlot': _selectedTimeSlot,
        'duration': _selectedDuration,
        'connectorType': _selectedConnector,
        'estimatedCost': _calculateEstimatedCost(),
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to confirmation screen
        Navigator.pushReplacementNamed(
          context,
          '/booking-confirmation',
          arguments: bookingData,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Book Charging Slot'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Station Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.ev_station,
                                color: Colors.green.shade700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _stationData['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _stationData['address'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Select Date
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Select Time Slot
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Time Slot',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2,
                          ),
                          itemCount: _timeSlots.length,
                          itemBuilder: (context, index) {
                            final slot = _timeSlots[index];
                            final isBooked = _bookedSlots.contains(slot);
                            final isSelected = _selectedTimeSlot == slot;

                            return InkWell(
                              onTap: isBooked
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedTimeSlot = slot;
                                      });
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? Colors.grey.shade200
                                      : isSelected
                                          ? Colors.green.shade600
                                          : Colors.white,
                                  border: Border.all(
                                    color: isBooked
                                        ? Colors.grey.shade300
                                        : isSelected
                                            ? Colors.green.shade600
                                            : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isBooked
                                          ? Colors.grey.shade500
                                          : isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildLegendItem(Colors.green.shade600, 'Selected'),
                            const SizedBox(width: 16),
                            _buildLegendItem(Colors.grey.shade300, 'Booked'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Select Duration
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Duration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _durations.map((duration) {
                            final isSelected = _selectedDuration == duration;
                            return ChoiceChip(
                              label: Text(duration),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDuration = duration;
                                });
                              },
                              selectedColor: Colors.green.shade600,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Select Connector Type
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Connector Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (_stationData['connectorTypes']
                                  as List<String>)
                              .map((connector) {
                            final isSelected = _selectedConnector == connector;
                            return ChoiceChip(
                              label: Text(connector),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedConnector = connector;
                                });
                              },
                              selectedColor: Colors.green.shade600,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cost Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cost Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rate',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Rs. ${_stationData['pricePerKwh']}/kWh',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Duration',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              _selectedDuration,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated Cost',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rs. ${_calculateEstimatedCost().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Final cost may vary based on actual usage',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: Container(
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
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}