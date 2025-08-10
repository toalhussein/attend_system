import 'dart:developer' as dev;

import 'package:attend_system/features/login_feature/presentation/manager/login_cubit.dart';
import 'package:attend_system/features/login_feature/presentation/manager/login_states.dart';
import 'package:attend_system/features/login_feature/presentation/views/widgets/employee_number_field.dart';
import 'package:attend_system/features/login_feature/presentation/views/widgets/login_button.dart';
import 'package:attend_system/features/login_feature/presentation/views/widgets/passoword_field.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/super_admin.dart';
import 'package:attend_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../../admin_feature/presentation/views/admin_view.dart';
import '../../../user_feature/presentation/views/user_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _workIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _workIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginStates>(
      listener: listener,
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is LoginLoading,
          child: Form(
            key: loginKey,
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App Logo and Title with animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildHeader(),
                            ),
                            const SizedBox(height: 40),

                            // Login Form Card with slide animation
                            SlideTransition(
                              position: _slideAnimation,
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildLoginCard(),
                              ),
                            ),

                            const SizedBox(height: 24),
                            // Footer text
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildFooter(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: const Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Color(0xFF667eea),
                ),
              )),
        ),
        const SizedBox(height: 24),
        const Text(
          'Attendance System',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Please sign in to continue',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Card(
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your credentials to access your account',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            EmployeeNumberField(
              workIdController: _workIdController,
            ),
            const SizedBox(height: 24),
            PassowordField(
              passwordController: _passwordController,
            ),
            const SizedBox(height: 32),
            LoginButton(
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Secure • Reliable • Efficient',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
      textAlign: TextAlign.center,
    );
  }

  void listener(BuildContext context, LoginStates state) {
    if (state is LoginFailed) {
      _showErrorDialog(context, state.errorMessage);
      dev.log('Login failed: ${state.errorMessage}');
    } else if (state is LoginSuccess) {
      saveUser(state.userID, state.userRole);
      _navigateToRolePage(state.userRole);
      _showToast('Login successful');
    }
  }

  void _login() {
    if (loginKey.currentState!.validate()) {
      BlocProvider.of<LoginCubit>(context).login(
        workId: _workIdController.text,
        password: _passwordController.text,
      );
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Login Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16),
              ),
              if (errorMessage.contains('permission-denied') || 
                  errorMessage.contains('Access denied')) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Troubleshooting:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Check your internet connection\n'
                        '• Verify your credentials\n'
                        '• Contact your system administrator\n'
                        '• Try again in a few minutes',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToRolePage(String role) async {
    Widget page;
    switch (role) {
      case 'employee':
        page = const EmployeePage();
        break;
      case 'admin':
        page = const AdminPage();
        break;
      case 'super_admin':
        page = const SuperAdminPage();
        break;
      default:
        _showToast('Invalid role');
        return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void saveUser(String userId, String role) {
    LocalStorage.userData.setString('id', userId);
    LocalStorage.userData.setString('role', role);
  }
}
