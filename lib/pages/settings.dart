import 'dart:io';
import 'package:eclapp/pages/addpayment.dart';
import 'package:eclapp/pages/changepassword.dart';
import 'package:eclapp/pages/privacypolicy.dart';
import 'package:eclapp/pages/profilescreen.dart';
import 'package:eclapp/pages/tandc.dart';
import 'package:eclapp/pages/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aboutus.dart';
import 'bottomnav.dart';
import 'cart.dart';
import 'loggedout.dart';
import 'notifications.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _userName = "User";
  String _userEmail = "No email available";
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profile_image_path');
    if (savedImagePath != null && await File(savedImagePath).exists()) {
      setState(() {
        _profileImage = File(savedImagePath);
        _profileImagePath = savedImagePath;
      });
    } else {
      print("Image file not found or path is null!");
    }
  }

  Future<void> _loadUserData() async {
    final secureStorage = FlutterSecureStorage();

    print("Loading User Data with keys: 'userName', 'userEmail', 'phoneNumber'");

    String name = await secureStorage.read(key: 'userName') ?? "User";
    String email = await secureStorage.read(key: 'userEmail') ?? "No email available";


    print("Retrieved User Data:");
    print("Name: $name");
    print("Email: $email");


    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  Future<void> _pickImage() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File savedImage = await _saveImageToLocalStorage(File(image.path));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', savedImage.path);

        setState(() {
          _profileImage = savedImage;
          _profileImagePath = savedImage.path;
        });
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<File> _saveImageToLocalStorage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImagePath = "${directory.path}/profile_image.png";
    final File savedImage = await imageFile.copy(savedImagePath);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', savedImagePath);
    return savedImage;
  }

  Widget _buildLogoutOption() {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text(
        "Logout",
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
      ),
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clear user data
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoggedOutScreen()),
              (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart())),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_profileImagePath != null && File(_profileImagePath!).existsSync()
                          ? FileImage(File(_profileImagePath!))
                          : const AssetImage("assets/images/default_avatar.png") as ImageProvider),
                      child: _profileImage == null && _profileImagePath == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildSettingsSection("Account Settings", [
                _buildSettingOption("Profile Information", Icons.edit, ProfileScreen()),
                _buildSettingOption("Change password", Icons.key, ChangePasswordPage()),
                _buildSettingOption("Add a payment method", Icons.payment, AddPaymentPage()),
              ]),
              SizedBox(height: 10),
              _buildSettingsSection("General", [
                _buildSettingOption("Push notifications", Icons.notifications, NotificationsScreen()),
                _buildDarkModeToggle(themeProvider),
              ]),
              SizedBox(height: 10),
              _buildSettingsSection("More", [
                _buildSettingOption("About us", Icons.info_outline, AboutUsScreen()),
                _buildSettingOption("Privacy policy", Icons.lock_outline, PrivacyPolicyScreen()),
                _buildSettingOption("Terms and conditions", Icons.description, TermsAndConditionsScreen()),
              ]),
              SizedBox(height: 20),
              _buildLogoutOption(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> options) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...options,
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(ThemeProvider themeProvider) {
    return ListTile(
      leading: Icon(Icons.brightness_4, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      title: Text(
        "Dark Mode",
        style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildSettingOption(String text, IconData icon, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: GoogleFonts.poppins(fontSize: 16)),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}