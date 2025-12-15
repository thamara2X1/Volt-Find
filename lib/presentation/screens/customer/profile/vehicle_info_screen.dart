import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_find/presentation/providers/user_provider.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleTypeController;
  String? _selectedVehicleType;

  final List<String> _vehicleTypes = [
    'Tesla Model 3',
    'Tesla Model Y',
    'Tesla Model S',
    'Tesla Model X',
    'Nissan Leaf',
    'Chevrolet Bolt',
    'BMW i4',
    'Audi e-tron',
    'Ford Mustang Mach-E',
    'Hyundai Ioniq 5',
    'Kia EV6',
    'Rivian R1T',
    'Lucid Air',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    
    _vehicleModelController = TextEditingController(text: user?.vehicleModel ?? '');
    _vehicleTypeController = TextEditingController(text: user?.vehicleType ?? '');
    _selectedVehicleType = user?.vehicleType;
  }

  @override
  void dispose() {
    _vehicleModelController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  Future<void> _updateVehicleInfo() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();

      try {
        await userProvider.updateVehicleInfo(
          vehicleModel: _vehicleModelController.text,
          vehicleType: _selectedVehicleType,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle information updated!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update vehicle info: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Vehicle Information'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _updateVehicleInfo,
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle Illustration
                    Center(
                      child: Container(
                        width: 200,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.electric_car,
                          size: 80,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Vehicle Model Field
                    Text(
                      'Vehicle Model',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _vehicleModelController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Tesla Model 3, Nissan Leaf',
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your vehicle model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Type Dropdown
                    Text(
                      'Vehicle Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: InputDecoration(
                        hintText: 'Select vehicle type',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _vehicleTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select vehicle type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Connector Type Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your vehicle info helps us find compatible charging stations',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 14,
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
                      child: ElevatedButton(
                        onPressed: _updateVehicleInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: userProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Vehicle Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Common EV Models
                    Text(
                      'Common EV Models',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _vehicleTypes.map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _selectedVehicleType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedVehicleType = selected ? type : null;
                              _vehicleModelController.text = type;
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: Colors.green.shade100,
                          labelStyle: TextStyle(
                            color: _selectedVehicleType == type
                                ? Colors.green.shade800
                                : Colors.grey.shade700,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}