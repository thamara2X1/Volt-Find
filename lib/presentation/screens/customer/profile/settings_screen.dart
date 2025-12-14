import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationServices = true;
  bool _autoBooking = false;
  bool _showAvailableOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Settings
            _buildSettingsSection(
              title: 'Notifications',
              children: [
                _buildSettingsSwitch(
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts for station availability',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Booking Reminders',
                  subtitle: 'Get reminders before your booking starts',
                  value: true,
                  onChanged: (value) {},
                ),
                _buildSettingsSwitch(
                  title: 'Promotional Offers',
                  subtitle: 'Receive special offers and discounts',
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Preferences
            _buildSettingsSection(
              title: 'App Preferences',
              children: [
                _buildSettingsSwitch(
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Location Services',
                  subtitle: 'Allow access to your location',
                  value: _locationServices,
                  onChanged: (value) {
                    setState(() {
                      _locationServices = value;
                    });
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Auto Booking',
                  subtitle: 'Automatically book nearest available station',
                  value: _autoBooking,
                  onChanged: (value) {
                    setState(() {
                      _autoBooking = value;
                    });
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Show Available Only',
                  subtitle: 'Only show stations with available slots',
                  value: _showAvailableOnly,
                  onChanged: (value) {
                    setState(() {
                      _showAvailableOnly = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Map Settings
            _buildSettingsSection(
              title: 'Map Settings',
              children: [
                _buildSettingsTile(
                  title: 'Default Map Style',
                  subtitle: 'Standard',
                  icon: Icons.map_outlined,
                  onTap: () {},
                ),
                _buildSettingsTile(
                  title: 'Search Radius',
                  subtitle: '10 km',
                  icon: Icons.radio_outlined,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Storage
            _buildSettingsSection(
              title: 'Data & Storage',
              children: [
                _buildSettingsTile(
                  title: 'Clear Cache',
                  subtitle: '256 MB used',
                  icon: Icons.storage_outlined,
                  onTap: () {},
                ),
                _buildSettingsTile(
                  title: 'Data Usage',
                  subtitle: 'Optimized',
                  icon: Icons.data_usage_outlined,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Version
            Center(
              child: Text(
                'VoltFind v1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green.shade600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.green.shade600),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}