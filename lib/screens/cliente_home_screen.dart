import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyectofinal/screens/login_screen.dart';
import 'package:proyectofinal/screens/search_doctors_screen.dart';

class ClienteScreen extends StatefulWidget {
  @override
  _ClienteScreenState createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getHorariosDisponibles() async {
    final horariosSnapshot = await _firestore.collection('medicos').get();

    List<Map<String, dynamic>> horariosDisponibles = [];

    for (var medicoDoc in horariosSnapshot.docs) {
      final horariosMedicoSnapshot = await _firestore
          .collection('medicos')
          .doc(medicoDoc.id)
          .collection('horarios')
          .where('disponibilidad', isEqualTo: true)
          .get();

      for (var horarioDoc in horariosMedicoSnapshot.docs) {
        horariosDisponibles.add({
          'medico': medicoDoc['nombre'],
          'fecha': horarioDoc['fecha'],
          'hora': horarioDoc['hora'],
          'medicoId': medicoDoc.id,
          'horarioId': horarioDoc.id
        });
      }
    }

    return horariosDisponibles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios Disponibles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getHorariosDisponibles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay horarios disponibles.'));
            }

            final horarios = snapshot.data!;
            return ListView.builder(
              itemCount: horarios.length,
              itemBuilder: (context, index) {
                final horario = horarios[index];
                return ListTile(
                  title: Text(
                      '${horario['medico']} - ${horario['fecha']} ${horario['hora']}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _reservarCita(horario['medicoId'], horario['horarioId']);
                    },
                    child: const Text('Reservar'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BusquedaMedicosScreen()),
          );
        },
        child: Icon(Icons.search),
        tooltip: 'Buscar Médicos',
      ),
    );
  }

  Future<void> _reservarCita(String medicoId, String horarioId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes iniciar sesión para reservar una cita.')),
      );
      return;
    }

    try {
      await _firestore.collection('reservas').add({
        'clienteId': currentUser.uid,
        'medicoId': medicoId,
        'horarioId': horarioId,
        'fechaReserva': Timestamp.now(),
      });

      await _firestore
          .collection('medicos')
          .doc(medicoId)
          .collection('horarios')
          .doc(horarioId)
          .update({
        'disponibilidad': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cita reservada con éxito.')),
      );
    } catch (e) {
      print('Error al reservar la cita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al reservar la cita. Intenta nuevamente.')),
      );
    }
  }
}
