
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = AuthService();

//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
          
//           if (snapshot.hasData) {
//             User user = snapshot.data!;

//             return FutureBuilder<String?>(
//               future: authService.getUserRole(user.uid),
//               builder: (context, roleSnapshot) {
//                 if (roleSnapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (roleSnapshot.hasError || !roleSnapshot.hasData) {
//                   return const Center(child: Text('Failed to fetch user role.'));
//                 }

//                 String? userRole = roleSnapshot.data;
//                 if (userRole == UserRole.kasir.name) {
//                   return PencatatanTransaksiPage();
//                 } else if (userRole == UserRole.admin.name) {
//                   return const HomePage();
//                 } else {
//                   return const Center(child: Text('Unauthorized user role.'));
//                 }
//               },
//             );
//           } else {
//             return const LoginOrRegister();
//           }
//         },
//       ),
//     );
//   }
// }
