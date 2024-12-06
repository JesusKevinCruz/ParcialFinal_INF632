import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/cliente_home_screen.dart';
import 'screens/medico_home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Citas Médicas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/cliente': (context) => ClienteScreen(),
        '/medico': (context) => MedicoScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return LoginScreen();
        }

        final user = snapshot.data!;
        final uid = user.uid;

        return FutureBuilder<bool>(
          future: _checkUserType(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null || !snapshot.data!) {
              return RegisterScreen();
            }

            final userType = snapshot.data!;

            if (userType == true) {
              return ClienteScreen();
            } else {
              return MedicoScreen();
            }
          },
        );
      },
    );
  }

  Future<bool> _checkUserType(String uid) async {
    final clienteDoc = await _firestore.collection('clientes').doc(uid).get();
    if (clienteDoc.exists) {
      return true;
    }

    final medicoDoc = await _firestore.collection('medicos').doc(uid).get();
    if (medicoDoc.exists) {
      return false;
    }

    return false;
  }
}
