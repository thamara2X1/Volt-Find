import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volt_find/presentation/providers/app_theme_provider.dart';
import 'package:volt_find/widgets/custom_bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<SharedPreferences> _prefsFuture;

  // ─── Non-theme settings (persisted via SharedPreferences) ───────────────────
  bool _notificationsEnabled = true;
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

  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;

  // ─── Deletion state ──────────────────────────────────────────────────────────
  bool _isDeletingAccount = false;

  final List<String> _mapStyles = ['Standard', 'Satellite', 'Terrain', 'Night'];
  final List<String> _searchRadii = ['5 km', '10 km', '15 km', '20 km', '30 km'];
  final List<String> _languages = ['English', 'සිංහල', 'தமிழ்'];
  final List<String> _currencies = ['Rs. (LKR)', '\$ (USD)', '€ (EUR)', '£ (GBP)'];

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
    _loadSettings();
    _loadUserData();
  }

  // ─── Load user from Firestore ────────────────────────────────────────────────
  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (mounted) {
          setState(() {
            _userData = doc.exists ? doc.data() : null;
            _isLoadingUser = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingUser = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  // ─── Load non-theme preferences ──────────────────────────────────────────────
  Future<void> _loadSettings() async {
    try {
      final prefs = await _prefsFuture;
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
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
    } catch (_) {}
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await _prefsFuture;
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (_) {}
  }

  // ─── Delete Account ──────────────────────────────────────────────────────────
  /// Step 1 — warn the user what will be lost
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. The following will be permanently deleted:\n\n'
          '• Profile information\n'
          '• Booking history\n'
          '• Favourite stations\n'
          '• Payment methods\n\n'
          'Your account will be deactivated immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showFinalConfirmationDialog();
            },
            child: Text('Continue',
                style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }

  /// Step 2 — final "are you absolutely sure?" gate
  void _showFinalConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Are you absolutely sure?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type DELETE to confirm permanent account deletion.',
            ),
            const SizedBox(height: 16),
            _DeleteConfirmationField(
              onConfirmed: () {
                Navigator.pop(ctx);
                _executeAccountDeletion();
              },
              onCancelled: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3 — mark account as deleted in Firestore, then sign out
  Future<void> _executeAccountDeletion() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isDeletingAccount = true);

    try {
      // Mark as deleted / inactive in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'isActive': false,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletionReason': 'user_requested',
      });

      // Also write to a deletedAccounts collection for admin audit trail
      await _firestore.collection('deletedAccounts').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'deletedAt': FieldValue.serverTimestamp(),
        'reason': 'user_requested',
      });

      // Sign the user out — AuthWrapper will detect this and redirect
      await _auth.signOut();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─── Cache clear ─────────────────────────────────────────────────────────────
  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache'),
        content: const Text('Clear all locally cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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

  // ─── Picker dialogs ──────────────────────────────────────────────────────────
  void _showPickerDialog<T>({
    required String title,
    required List<T> items,
    required T current,
    required void Function(T) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final isSelected = item == current;
              return ListTile(
                title: Text(item.toString()),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.green.shade600)
                    : null,
                tileColor: isSelected
                    ? Colors.green.shade50.withOpacity(0.5)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  onSelected(item);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Listen to theme provider so the switch stays in sync
    final themeProvider = context.watch<AppThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    final user = _auth.currentUser;

    // Overlay for account deletion
    if (_isDeletingAccount) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 24),
              const Text(
                'Deleting your account…',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a moment.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Info Card ────────────────────────────────────────────────
            if (user != null && !_isLoadingUser) _buildUserCard(user),
            if (_isLoadingUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              ),

            const SizedBox(height: 24),

            // ── Appearance (Dark Mode lives here, driven by Provider) ────────
            _buildSection(
              title: 'Appearance',
              children: [
                _buildProviderSwitch(
                  title: 'Dark Mode',
                  subtitle: isDark
                      ? 'Using dark theme'
                      : 'Using light theme',
                  value: isDark,
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  onChanged: (val) =>
                      context.read<AppThemeProvider>().setDarkMode(val),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Notifications ─────────────────────────────────────────────────
            _buildSection(
              title: 'Notifications',
              children: [
                _buildSwitch(
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts for station availability',
                  value: _notificationsEnabled,
                  onChanged: (v) {
                    setState(() => _notificationsEnabled = v);
                    _saveSetting('notificationsEnabled', v);
                  },
                ),
                _buildSwitch(
                  title: 'Booking Reminders',
                  subtitle: 'Get reminders before your booking starts',
                  value: _bookingReminders,
                  onChanged: (v) {
                    setState(() => _bookingReminders = v);
                    _saveSetting('bookingReminders', v);
                  },
                ),
                _buildSwitch(
                  title: 'Promotional Offers',
                  subtitle: 'Receive special offers and discounts',
                  value: _promotionalOffers,
                  onChanged: (v) {
                    setState(() => _promotionalOffers = v);
                    _saveSetting('promotionalOffers', v);
                  },
                ),
                _buildSwitch(
                  title: 'Station Updates',
                  subtitle: 'Get notified when favourite stations update',
                  value: _stationUpdates,
                  onChanged: (v) {
                    setState(() => _stationUpdates = v);
                    _saveSetting('stationUpdates', v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── App Preferences ───────────────────────────────────────────────
            _buildSection(
              title: 'App Preferences',
              children: [
                _buildSwitch(
                  title: 'Location Services',
                  subtitle: 'Allow access to your location',
                  value: _locationServices,
                  onChanged: (v) {
                    setState(() => _locationServices = v);
                    _saveSetting('locationServices', v);
                  },
                ),
                _buildSwitch(
                  title: 'Auto Booking',
                  subtitle: 'Automatically book nearest available station',
                  value: _autoBooking,
                  onChanged: (v) {
                    setState(() => _autoBooking = v);
                    _saveSetting('autoBooking', v);
                  },
                ),
                _buildSwitch(
                  title: 'Show Available Only',
                  subtitle: 'Only show stations with available slots',
                  value: _showAvailableOnly,
                  onChanged: (v) {
                    setState(() => _showAvailableOnly = v);
                    _saveSetting('showAvailableOnly', v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Display Settings ──────────────────────────────────────────────
            _buildSection(
              title: 'Display Settings',
              children: [
                _buildTile(
                  title: 'Language',
                  subtitle: _language,
                  icon: Icons.language_outlined,
                  onTap: () => _showPickerDialog(
                    title: 'Select Language',
                    items: _languages,
                    current: _language,
                    onSelected: (v) {
                      setState(() => _language = v);
                      _saveSetting('language', v);
                    },
                  ),
                ),
                _buildTile(
                  title: 'Currency',
                  subtitle: _currency,
                  icon: Icons.currency_exchange_outlined,
                  onTap: () => _showPickerDialog(
                    title: 'Select Currency',
                    items: _currencies,
                    current: _currency,
                    onSelected: (v) {
                      setState(() => _currency = v);
                      _saveSetting('currency', v);
                    },
                  ),
                ),
                _buildTile(
                  title: 'Map Style',
                  subtitle: _mapStyle,
                  icon: Icons.map_outlined,
                  onTap: () => _showPickerDialog(
                    title: 'Select Map Style',
                    items: _mapStyles,
                    current: _mapStyle,
                    onSelected: (v) {
                      setState(() => _mapStyle = v);
                      _saveSetting('mapStyle', v);
                    },
                  ),
                ),
                _buildTile(
                  title: 'Search Radius',
                  subtitle: _searchRadius,
                  icon: Icons.radar_outlined,
                  onTap: () => _showPickerDialog(
                    title: 'Select Search Radius',
                    items: _searchRadii,
                    current: _searchRadius,
                    onSelected: (v) {
                      setState(() => _searchRadius = v);
                      _saveSetting('searchRadius', v);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Data & Storage ────────────────────────────────────────────────
            _buildSection(
              title: 'Data & Storage',
              children: [
                _buildTile(
                  title: 'Clear Cache',
                  subtitle: 'Remove all locally cached data',
                  icon: Icons.cleaning_services_outlined,
                  onTap: _clearCache,
                ),
                _buildTile(
                  title: 'Data Usage',
                  subtitle: 'Optimised for mobile data',
                  icon: Icons.data_usage_outlined,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Data Usage'),
                        content: const Text(
                          '• Images: Compressed\n'
                          '• Maps: Cached offline\n'
                          '• Updates: Only on WiFi\n'
                          '• Sync: Every 30 minutes',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Account & Privacy ─────────────────────────────────────────────
            _buildSection(
              title: 'Account & Privacy',
              children: [
                _buildTile(
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _showStaticDialog(
                    title: 'Privacy Policy',
                    content:
                        'VoltFind EV Charging App Privacy Policy\n\n'
                        '1. Data Collection\nWe collect essential information to provide EV charging services.\n\n'
                        '2. Location Data\nUsed only to find nearby charging stations.\n\n'
                        '3. User Information\nStored securely for booking and authentication.\n\n'
                        '4. Third-Party Services\nWe use Firebase for backend services.\n\n'
                        '5. Your Rights\nYou can delete your account anytime.',
                  ),
                ),
                _buildTile(
                  title: 'Terms of Service',
                  subtitle: 'User agreement',
                  icon: Icons.description_outlined,
                  onTap: () => _showStaticDialog(
                    title: 'Terms of Service',
                    content:
                        'VoltFind EV Charging — Terms of Service\n\n'
                        '1. Service Usage\nApp is for personal EV charging needs only.\n\n'
                        '2. Booking Policy\nCancellations must be made 30 minutes prior.\n\n'
                        '3. Payments\nAll charges are in local currency.\n\n'
                        '4. Liability\nWe are not responsible for vehicle damage.\n\n'
                        '5. Account Termination\nViolations may result in account suspension.',
                  ),
                ),
                _buildTile(
                  title: 'Delete Account',
                  subtitle: 'Permanently deactivate your account',
                  icon: Icons.person_remove_outlined,
                  onTap: _showDeleteAccountDialog,
                  isDanger: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── App Info ──────────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'VoltFind EV Charging',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (Build 1001)',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 VoltFind. All rights reserved.',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  // ─── Reusable widgets ────────────────────────────────────────────────────────

  Widget _buildUserCard(User user) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            backgroundColor: colorScheme.primary.withOpacity(0.12),
            backgroundImage: _userData?['photoUrl'] != null
                ? NetworkImage(_userData!['photoUrl'] as String)
                : null,
            child: _userData?['photoUrl'] == null
                ? Icon(Icons.person, size: 30, color: colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?['name'] ?? user.displayName ?? 'User',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _userData?['email'] ?? user.email ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _intersperse(children),
          ),
        ),
      ],
    );
  }

  /// Thin divider between list tiles
  List<Widget> _intersperse(List<Widget> items) {
    if (items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(const Divider(height: 1, indent: 56, endIndent: 16));
      }
    }
    return result;
  }

  /// Switch driven directly by Provider (e.g. Dark Mode)
  Widget _buildProviderSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.primary,
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(title,
          style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  /// Switch backed by SharedPreferences
  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.primary,
      title: Text(title,
          style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isDanger ? Colors.red.shade600 : colorScheme.primary;
    final iconBg = isDanger
        ? Colors.red.shade50
        : colorScheme.primary.withOpacity(0.10);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red.shade700 : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDanger ? Colors.red.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDanger ? Colors.red.shade300 : Colors.grey.shade400,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  void _showStaticDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ─── Delete confirmation field widget ─────────────────────────────────────────

class _DeleteConfirmationField extends StatefulWidget {
  final VoidCallback onConfirmed;
  final VoidCallback onCancelled;

  const _DeleteConfirmationField({
    required this.onConfirmed,
    required this.onCancelled,
  });

  @override
  State<_DeleteConfirmationField> createState() =>
      _DeleteConfirmationFieldState();
}

class _DeleteConfirmationFieldState
    extends State<_DeleteConfirmationField> {
  final _controller = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final isValid = _controller.text.trim() == 'DELETE';
      if (isValid != _valid) setState(() => _valid = isValid);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'Type DELETE',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _valid ? Colors.red.shade400 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _valid ? Colors.red.shade600 : Colors.grey.shade400,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onCancelled,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _valid ? widget.onConfirmed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                disabledBackgroundColor: Colors.red.shade200,
              ),
              child: const Text('Delete My Account'),
            ),
          ],
        ),
      ],
    );
  }
}