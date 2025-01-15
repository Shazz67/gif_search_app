import 'package:flutter/material.dart';
import '../widgets/shared/gradient_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Settings',
        titleOffset: -18.0,
        height: Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 0,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable notifications',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: Color.fromARGB(255, 61, 61, 255),
                  activeTrackColor: Color.fromARGB(70, 61, 61, 255),
                  inactiveThumbColor: Color.fromARGB(255, 189, 189, 238),
                  inactiveTrackColor: Color.fromARGB(255, 243, 243, 246),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 0,
              bottom: 4,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable dark mode',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                  activeColor: Color.fromARGB(255, 255, 0, 93),
                  activeTrackColor: Color.fromARGB(70, 255, 0, 93),
                  inactiveThumbColor: Color.fromARGB(255, 242, 184, 184),
                  inactiveTrackColor: Color.fromARGB(255, 243, 243, 246),
                ),
              ],
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 16,
              right: 22,
            ),
            title: const Text(
              'Manage Account',
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 16,
              right: 22,
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 16,
              right: 22,
            ),
            title: const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
