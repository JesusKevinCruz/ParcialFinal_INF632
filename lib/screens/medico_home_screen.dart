import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyectofinal/screens/login_screen.dart';

class MedicoScreen extends StatefulWidget {
  @override
  _MedicoScreenState createState() => _MedicoScreenState();
}

class _MedicoScreenState extends State<MedicoScreen> {
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _medicoId {
    return _auth.currentUser?.uid ?? '';
  }

  Future<List<Map<String, dynamic>>> _getHorarios() async {
    final horariosSnapshot = await _firestore
        .collection('medicos')
        .doc(_medicoId)
        .collection('horarios')
        .get();

    List<Map<String, dynamic>> horarios = [];
    for (var doc in horariosSnapshot.docs) {
      horarios.add(doc.data() as Map<String, dynamic>);
    }
    return horarios;
  }

  Future<void> _addHorario() async {
    if (fechaController.text.isNotEmpty && horaController.text.isNotEmpty) {
      await _firestore
          .collection('medicos')
          .doc(_medicoId)
          .collection('horarios')
          .add({
        'fecha': fechaController.text,
        'hora': horaController.text,
        'disponibilidad': true,
      });

      fechaController.clear();
      horaController.clear();
      setState(() {});
    }
  }

  Future<void> _deleteHorario(String horarioId) async {
    if (horarioId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('medicos')
            .doc(_medicoId)
            .collection('horarios')
            .doc(horarioId)
            .delete();

        setState(() {});
      } catch (e) {
        print('Error al eliminar el horario: $e');
      }
    } else {
      print("El ID del horario es nulo o vacío.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil de Médico'),
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
        child: Column(
          children: [
            TextField(
              controller: fechaController,
              decoration:
                  const InputDecoration(labelText: 'Fecha (yyyy-mm-dd)'),
            ),
            TextField(
              controller: horaController,
              decoration: const InputDecoration(labelText: 'Hora (hh:mm)'),
            ),
            ElevatedButton(
              onPressed: _addHorario,
              child: const Text('Agregar Horario'),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('medicos')
                    .doc(_medicoId)
                    .collection('horarios')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No hay horarios disponibles.'));
                  }

                  final horarios = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: horarios.length,
                    itemBuilder: (context, index) {
                      final horario = horarios[index];
                      final horarioId = horario.id;

                      return ListTile(
                        title: Text('${horario['fecha']} - ${horario['hora']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteHorario(horarioId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
