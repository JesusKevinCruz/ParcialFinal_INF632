import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

final AuthService _authService = AuthService();
final FirestoreService _firestoreService = FirestoreService();

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController especialidadController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();

  String userType = 'cliente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            DropdownButtonFormField(
              value: userType,
              items: [
                DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                DropdownMenuItem(value: 'medico', child: Text('Médico')),
              ],
              onChanged: (value) {
                setState(() {
                  userType = value!;
                });
              },
            ),
            if (userType == 'medico') ...[
              TextField(
                controller: especialidadController,
                decoration: const InputDecoration(labelText: 'Especialidad'),
              ),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (userType == 'cliente') {
                  final user = await _authService.registerCliente(
                    nombreController.text,
                    emailController.text,
                    passwordController.text,
                  );
                  if (user != null) {
                    await _firestoreService.saveCliente(
                        user.uid, nombreController.text, emailController.text);
                    Navigator.pushReplacementNamed(context, '/cliente');
                  }
                } else {
                  final user = await _authService.registerMedico(
                    nombreController.text,
                    emailController.text,
                    passwordController.text,
                  );
                  if (user != null) {
                    await _firestoreService.saveMedico(
                      user.uid,
                      nombreController.text,
                      emailController.text,
                      especialidadController.text,
                      ubicacionController.text,
                    );
                    Navigator.pushReplacementNamed(context, '/medico');
                  }
                }
              },
              child: const Text('Registrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Volver al login'),
            )
          ],
        ),
      ),
    );
  }
}
