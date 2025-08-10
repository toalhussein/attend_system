import 'package:attend_system/features/login_feature/presentation/manager/login_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInitialState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void login({required String workId, required String password}) async {
    emit(LoginLoading());
    try {
      // Input validation
      if (workId.trim().isEmpty || password.trim().isEmpty) {
        emit(LoginFailed(errorMessage: 'Please fill in all fields'));
        return;
      }

      // Try anonymous authentication first to get access
      await _ensureAuthenticated();
      
      final QuerySnapshot snapshot =
          await getUser(workId: workId.trim(), password: password);

      checkUserAvailability(snapshot, workId.trim());
    } on FirebaseAuthException catch (e) {
      emit(LoginFailed(errorMessage: 'Authentication error: ${e.message}'));
    } on FirebaseException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'permission-denied':
          errorMessage = 'Access denied. Please check your Firestore security rules.';
          break;
        case 'unavailable':
          errorMessage = 'Service temporarily unavailable. Please try again later.';
          break;
        case 'unauthenticated':
          errorMessage = 'Authentication required. Please contact support.';
          break;
        default:
          errorMessage = 'Connection error: ${e.message}';
      }
      emit(LoginFailed(errorMessage: errorMessage));
    } catch (e) {
      emit(LoginFailed(errorMessage: 'Login failed: ${e.toString()}'));
    }
  }

  // Ensure user is authenticated (anonymous auth for database access)
  Future<void> _ensureAuthenticated() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUser(
      {required String workId, required String password}) async {
    try {
      return await _firestore
          .collection('users')
          .where('work_id', isEqualTo: workId)
          .where('password', isEqualTo: password)
          .limit(1) // Optimize query
          .get();
    } catch (e) {
      throw Exception('Database connection failed: ${e.toString()}');
    }
  }

  void checkUserAvailability(QuerySnapshot<Object?> snapshot, String workId) {
    if (snapshot.docs.isNotEmpty) {
      final userDoc = snapshot.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;
      
      final userRole = userData['role'] as String?;
      final userId = userDoc.id;
      final isActive = userData['is_active'] ?? true;
      
      // Check if user account is active
      if (!isActive) {
        emit(LoginFailed(errorMessage: 'Account is deactivated. Please contact admin.'));
        return;
      }
      
      // Validate role
      if (userRole == null || userRole.isEmpty) {
        emit(LoginFailed(errorMessage: 'User role not found. Please contact admin.'));
        return;
      }
      
      // Validate role is allowed
      final allowedRoles = ['employee', 'admin', 'super_admin'];
      if (!allowedRoles.contains(userRole)) {
        emit(LoginFailed(errorMessage: 'Invalid user role. Please contact admin.'));
        return;
      }
      
      emit(LoginSuccess(userRole: userRole, userID: userId));
    } else {
      emit(LoginFailed(errorMessage: 'Invalid Work ID or Password'));
    }
  }

  // Optional: Hash password for security (implement if using hashed passwords)
  // String _hashPassword(String password) {
  //   var bytes = utf8.encode(password);
  //   var digest = sha256.convert(bytes);
  //   return digest.toString();
  // }

  // Optional: Logout function
  void logout() {
    emit(LoginInitialState());
  }
}




//       if (snapshot.docs.isNotEmpty) {
//         final userRole = snapshot.docs.first['role'] as String?;

//         if (userRole == null || userRole.isEmpty) {
//           emit(LoginFailed(errorMessage: 'Role is missing for this user'));
//         } else {
//           await _navigateToRolePage(userRole, doc.id);
//         }
//       } else {
//         _showToast('Invalid Work ID or Password');
//       }