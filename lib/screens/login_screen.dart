import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  Future<void> _login() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        final clienteDoc = await FirebaseFirestore.instance
            .collection('clientes')
            .doc(uid)
            .get();

        if (clienteDoc.exists) {
          Navigator.pushReplacementNamed(context, '/cliente');
          return;
        }

        final medicoDoc = await FirebaseFirestore.instance
            .collection('medicos')
            .doc(uid)
            .get();

        if (medicoDoc.exists) {
          Navigator.pushReplacementNamed(context, '/medico');
          return;
        }

        setState(() {
          errorMessage = 'Usuario no encontrado en el sistema';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Correo o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Iniciar sesión'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
