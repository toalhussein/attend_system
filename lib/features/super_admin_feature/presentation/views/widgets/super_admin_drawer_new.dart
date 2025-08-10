import 'package:attend_system/core/widgets/custom_logout_icon.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/widgets/user_details.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/widgets/delete_user.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/widgets/feature_not_available_dialog.dart';
import 'package:flutter/material.dart';

import 'create_user.dart';

class SuperAdminDrawer extends StatelessWidget {
  const SuperAdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2196F3),
                    Color(0xFF1976D2),
                    Color(0xFF0D47A1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Super Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Administrative Panel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 16),
                    _buildMenuTile(
                      context,
                      title: 'Create User',
                      icon: Icons.person_add_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateUserPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      title: 'Delete User',
                      icon: Icons.person_remove_rounded,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeleteUserPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      title: 'Analysis Sheet',
                      icon: Icons.analytics_rounded,
                      onTap: () async {
                        Navigator.pop(context);
                        await showDialog(
                          context: context,
                          builder: (context) => const FeatureNotAvailableDialog(),
                        );
                      },
                    ),
                    _buildMenuTile(
                      context,
                      title: 'User Details',
                      icon: Icons.person_search_rounded,
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserDetailsPage(
                              name: 'name',
                              workId: 'work_id',
                              role: 'role',
                              residenceCity: 'residence_city',
                              workCity: 'work_city',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    const CustomLogoutButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1976D2),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
        hoverColor: const Color(0xFF1976D2).withOpacity(0.05),
        splashColor: const Color(0xFF1976D2).withOpacity(0.1),
      ),
    );
  }
}
