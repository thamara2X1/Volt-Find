import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final List<Booking> _bookings = [
    Booking(
      id: 'B001',
      stationName: 'Tesla Supercharger Station',
      date: 'Dec 15, 2024',
      time: '10:30 AM - 12:30 PM',
      duration: '2 hours',
      price: 'Rs. 1,200',
      status: BookingStatus.completed,
      connectorType: 'Tesla Supercharger',
      energyCharged: '45 kWh',
    ),
    Booking(
      id: 'B002',
      stationName: 'EV Power Hub',
      date: 'Dec 14, 2024',
      time: '3:00 PM - 4:30 PM',
      duration: '1.5 hours',
      price: 'Rs. 850',
      status: BookingStatus.completed,
      connectorType: 'CCS Combo',
      energyCharged: '32 kWh',
    ),
    Booking(
      id: 'B003',
      stationName: 'City Charge Station',
      date: 'Dec 13, 2024',
      time: '9:00 AM - 10:00 AM',
      duration: '1 hour',
      price: 'Rs. 600',
      status: BookingStatus.cancelled,
      connectorType: 'Type 2',
      energyCharged: '20 kWh',
    ),
    Booking(
      id: 'B004',
      stationName: 'Mall Parking Charger',
      date: 'Dec 12, 2024',
      time: '2:00 PM - 5:00 PM',
      duration: '3 hours',
      price: 'Rs. 1,800',
      status: BookingStatus.completed,
      connectorType: 'CHAdeMO',
      energyCharged: '60 kWh',
    ),
    Booking(
      id: 'B005',
      stationName: 'Highway Charging Point',
      date: 'Dec 10, 2024',
      time: '11:00 AM - 1:00 PM',
      duration: '2 hours',
      price: 'Rs. 1,100',
      status: BookingStatus.completed,
      connectorType: 'CCS Combo',
      energyCharged: '40 kWh',
    ),
  ];

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _selectedFilter == 'all'
        ? _bookings
        : _bookings.where((b) => b.status.name == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Booking History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'Completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('cancelled', 'Cancelled'),
                  const SizedBox(width: 8),
                  _buildFilterChip('upcoming', 'Upcoming'),
                ],
              ),
            ),
          ),

          // Bookings List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different filter',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.green.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (booking.status) {
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Completed';
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusText = 'Cancelled';
        break;
      case BookingStatus.upcoming:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time_outlined;
        statusText = 'Upcoming';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking #${booking.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Station Name
          Text(
            booking.stationName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),

          // Booking Details
          _buildBookingDetail(
            icon: Icons.calendar_today_outlined,
            text: booking.date,
          ),
          const SizedBox(height: 4),
          _buildBookingDetail(
            icon: Icons.access_time_outlined,
            text: '${booking.time} (${booking.duration})',
          ),
          const SizedBox(height: 4),
          _buildBookingDetail(
            icon: Icons.ev_station_outlined,
            text: booking.connectorType,
          ),
          const SizedBox(height: 4),
          _buildBookingDetail(
            icon: Icons.bolt_outlined,
            text: 'Energy: ${booking.energyCharged}',
          ),

          const SizedBox(height: 12),

          // Price and Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (booking.status == BookingStatus.completed)
                OutlinedButton.icon(
                  onPressed: () {
                    // Handle review
                  },
                  icon: const Icon(Icons.star_outline, size: 16),
                  label: const Text('Rate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetail({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

enum BookingStatus { completed, cancelled, upcoming }

class Booking {
  final String id;
  final String stationName;
  final String date;
  final String time;
  final String duration;
  final String price;
  final BookingStatus status;
  final String connectorType;
  final String energyCharged;

  Booking({
    required this.id,
    required this.stationName,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.status,
    required this.connectorType,
    required this.energyCharged,
  });
}