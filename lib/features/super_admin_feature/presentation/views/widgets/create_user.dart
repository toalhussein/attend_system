import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _workIdController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  String _selectedRole = 'employee';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _roles = ['admin', 'employee'];

  void _createUser() async {
    final String name = _nameController.text.trim();
    final String password = _passwordController.text.trim();
    final String workId = _workIdController.text.trim();
    final String uid = _uidController.text.trim();

    if (name.isEmpty || password.isEmpty || workId.isEmpty || uid.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill in all fields');
      return;
    }

    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'password': password,
        'work_id': workId,
        'role': _selectedRole,
        'uid': uid,
      });

      Fluttertoast.showToast(msg: 'User created successfully');

      _nameController.clear();
      _passwordController.clear();
      _workIdController.clear();
      _uidController.clear();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create User',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(_getResponsivePadding(context)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _getMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create New User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a new user to the system',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Form Card
              Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        hint: 'Enter user\'s full name',
                      ),
                      
                      SizedBox(height: _getResponsiveSpacing(context)),
                      
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        hint: 'Enter secure password',
                        obscureText: true,
                      ),
                      
                      SizedBox(height: _getResponsiveSpacing(context)),
                      
                      _buildInputField(
                        controller: _workIdController,
                        label: 'Work ID',
                        icon: Icons.badge_outlined,
                        hint: 'Enter work identification',
                      ),
                      
                      SizedBox(height: _getResponsiveSpacing(context)),
                      
                      _buildInputField(
                        controller: _uidController,
                        label: 'User UID',
                        icon: Icons.fingerprint_rounded,
                        hint: 'Enter unique user ID',
                      ),
                      
                      SizedBox(height: _getResponsiveSpacing(context)),
                      
                      _buildRoleDropdown(),
                      
                      const SizedBox(height: 32),
                      
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  // Helper methods for responsive design
  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 32.0; // Desktop
    if (screenWidth > 600) return 24.0;  // Tablet
    return 16.0; // Mobile
  }

  double _getMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 600.0; // Desktop - constrain form width
    if (screenWidth > 600) return screenWidth * 0.8; // Tablet - 80% width
    return double.infinity; // Mobile - full width
  }

  double _getResponsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 24.0; // Tablet/Desktop
    return 20.0; // Mobile
  }

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 18.0; // Tablet/Desktop
    return 16.0; // Mobile
  }

  double _getResponsiveButtonHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 64.0; // Tablet/Desktop
    return 56.0; // Mobile
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1976D2),
              size: 24,
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getResponsivePadding(context),
            vertical: _getResponsiveSpacing(context) - 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        onChanged: (String? newValue) {
          setState(() {
            _selectedRole = newValue!;
          });
        },
        items: _roles.map<DropdownMenuItem<String>>((String role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Row(
              children: [
                Icon(
                  role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                  color: const Color(0xFF1976D2),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'User Role',
          prefixIcon: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Color(0xFF1976D2),
              size: 24,
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getResponsivePadding(context),
            vertical: _getResponsiveSpacing(context) - 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      height: _getResponsiveButtonHeight(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _createUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Create User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
