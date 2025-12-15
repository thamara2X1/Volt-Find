import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:volt_find/domain/entities/user.dart';
import 'package:volt_find/presentation/providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<SharedPreferences> _prefsFuture;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationServices = true;
  bool _autoBooking = false;
  bool _showAvailableOnly = true;
  bool _bookingReminders = true;
  bool _promotionalOffers = false;
  bool _stationUpdates = true;
  String _mapStyle = 'Standard';
  String _searchRadius = '10 km';
  String _language = 'English';
  String _currency = 'Rs. (LKR)';

  final List<String> _mapStyles = ['Standard', 'Satellite', 'Terrain', 'Night'];
  final List<String> _searchRadii = ['5 km', '10 km', '15 km', '20 km', '30 km'];
  final List<String> _languages = ['English', 'සිංහල', 'தமிழ்'];
  final List<String> _currencies = ['Rs. (LKR)', '\$ (USD)', '€ (EUR)', '£ (GBP)'];

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await _prefsFuture;
      setState(() {
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
        _locationServices = prefs.getBool('locationServices') ?? true;
        _autoBooking = prefs.getBool('autoBooking') ?? false;
        _showAvailableOnly = prefs.getBool('showAvailableOnly') ?? true;
        _bookingReminders = prefs.getBool('bookingReminders') ?? true;
        _promotionalOffers = prefs.getBool('promotionalOffers') ?? false;
        _stationUpdates = prefs.getBool('stationUpdates') ?? true;
        _mapStyle = prefs.getString('mapStyle') ?? 'Standard';
        _searchRadius = prefs.getString('searchRadius') ?? '10 km';
        _language = prefs.getString('language') ?? 'English';
        _currency = prefs.getString('currency') ?? 'Rs. (LKR)';
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await _prefsFuture;
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      print('Error saving setting $key: $e');
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return ListTile(
                title: Text(language),
                trailing: _language == language
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _language = language;
                  });
                  _saveSetting('language', language);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $language'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final currency = _currencies[index];
              return ListTile(
                title: Text(currency),
                trailing: _currency == currency
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _currency = currency;
                  });
                  _saveSetting('currency', currency);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Currency changed to $currency'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMapStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Map Style'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _mapStyles.length,
            itemBuilder: (context, index) {
              final style = _mapStyles[index];
              return ListTile(
                title: Text(style),
                trailing: _mapStyle == style
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _mapStyle = style;
                  });
                  _saveSetting('mapStyle', style);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSearchRadiusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Search Radius'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _searchRadii.length,
            itemBuilder: (context, index) {
              final radius = _searchRadii[index];
              return ListTile(
                title: Text(radius),
                trailing: _searchRadius == radius
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    _searchRadius = radius;
                  });
                  _saveSetting('searchRadius', radius);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _clearCache() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        final prefs = await _prefsFuture;
        await prefs.remove('cachedStations');
        await prefs.remove('cachedBookings');
        await prefs.remove('cachedUser');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cache cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear cache: $e'),
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
    final user = userProvider.user;

    return FutureBuilder<SharedPreferences>(
      future: _prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green.shade600,
              title: const Text('Settings'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Unable to load your settings. You can still use the app with default settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _prefsFuture = SharedPreferences.getInstance();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildSettingsScreen(user);
      },
    );
  }

  Widget _buildSettingsScreen(User? user) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            if (user != null)
              Container(
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: user.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                user.photoUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey.shade600,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (user.vehicleModel != null)
                            Text(
                              'Vehicle: ${user.vehicleModel}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

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
                    _saveSetting('notificationsEnabled', value);
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Booking Reminders',
                  subtitle: 'Get reminders before your booking starts',
                  value: _bookingReminders,
                  onChanged: (value) {
                    setState(() {
                      _bookingReminders = value;
                    });
                    _saveSetting('bookingReminders', value);
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Promotional Offers',
                  subtitle: 'Receive special offers and discounts',
                  value: _promotionalOffers,
                  onChanged: (value) {
                    setState(() {
                      _promotionalOffers = value;
                    });
                    _saveSetting('promotionalOffers', value);
                  },
                ),
                _buildSettingsSwitch(
                  title: 'Station Updates',
                  subtitle: 'Get notified when favorite stations update',
                  value: _stationUpdates,
                  onChanged: (value) {
                    setState(() {
                      _stationUpdates = value;
                    });
                    _saveSetting('stationUpdates', value);
                  },
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
                    _saveSetting('darkModeEnabled', value);
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
                    _saveSetting('locationServices', value);
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
                    _saveSetting('autoBooking', value);
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
                    _saveSetting('showAvailableOnly', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Display Settings
            _buildSettingsSection(
              title: 'Display Settings',
              children: [
                _buildSettingsTile(
                  title: 'Language',
                  subtitle: _language,
                  icon: Icons.language_outlined,
                  onTap: _showLanguageDialog,
                ),
                _buildSettingsTile(
                  title: 'Currency',
                  subtitle: _currency,
                  icon: Icons.currency_exchange_outlined,
                  onTap: _showCurrencyDialog,
                ),
                _buildSettingsTile(
                  title: 'Map Style',
                  subtitle: _mapStyle,
                  icon: Icons.map_outlined,
                  onTap: _showMapStyleDialog,
                ),
                _buildSettingsTile(
                  title: 'Search Radius',
                  subtitle: _searchRadius,
                  icon: Icons.radio_outlined,
                  onTap: _showSearchRadiusDialog,
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
                  subtitle: 'Clear all cached data',
                  icon: Icons.storage_outlined,
                  onTap: _clearCache,
                ),
                _buildSettingsTile(
                  title: 'Data Usage',
                  subtitle: 'Optimized for mobile data',
                  icon: Icons.data_usage_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Data Usage'),
                        content: const Text(
                          'App uses optimized data settings:\n\n'
                          '• Images: Compressed\n'
                          '• Maps: Cached offline\n'
                          '• Updates: Only on WiFi\n'
                          '• Sync: Every 30 minutes',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  title: 'Download Offline Maps',
                  subtitle: 'Available for current area',
                  icon: Icons.download_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Offline maps download started'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account & Privacy
            _buildSettingsSection(
              title: 'Account & Privacy',
              children: [
                _buildSettingsTile(
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Privacy Policy'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'VoltFind EV Charging App Privacy Policy\n\n'
                            '1. Data Collection\n'
                            'We collect essential information to provide EV charging services.\n\n'
                            '2. Location Data\n'
                            'Used only to find nearby charging stations.\n\n'
                            '3. User Information\n'
                            'Stored securely for booking and authentication.\n\n'
                            '4. Third-Party Services\n'
                            'We use Firebase for backend services.\n\n'
                            '5. Your Rights\n'
                            'You can delete your account anytime.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  title: 'Terms of Service',
                  subtitle: 'User agreement',
                  icon: Icons.description_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Terms of Service'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'VoltFind EV Charging - Terms of Service\n\n'
                            '1. Service Usage\n'
                            'App is for personal EV charging needs only.\n\n'
                            '2. Booking Policy\n'
                            'Cancellations must be made 30 minutes prior.\n\n'
                            '3. Payments\n'
                            'All charges are in local currency.\n\n'
                            '4. Liability\n'
                            'We are not responsible for vehicle damage.\n\n'
                            '5. Account Termination\n'
                            'Violations may result in account suspension.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your account',
                  icon: Icons.delete_outline,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                  isDanger: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'VoltFind EV Charging',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (Build 1001)',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 VoltFind. All rights reserved.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
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
    bool isDanger = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDanger ? Colors.red.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDanger ? Colors.red.shade600 : Colors.green.shade600,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red.shade700 : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDanger ? Colors.red.shade600 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDanger ? Colors.red.shade400 : Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data, including:\n\n'
          '• Profile information\n'
          '• Booking history\n'
          '• Favorite stations\n'
          '• Payment methods\n\n'
          'Will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount(context);
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you absolutely sure? This action is permanent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request sent. You will receive a confirmation email.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Yes, Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}