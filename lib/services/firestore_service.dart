import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveCliente(String uid, String nombre, String email) async {
    try {
      await _db.collection('clientes').doc(uid).set({
        'nombre': nombre,
        'email': email,
        'tipo': 'cliente',
      });
    } catch (e) {
      print('Error al guardar cliente: $e');
    }
  }

  Future<void> saveMedico(String uid, String nombre, String email,
      String especialidad, String ubicacion) async {
    try {
      await _db.collection('medicos').doc(uid).set({
        'nombre': nombre,
        'email': email,
        'especialidad': especialidad,
        'ubicacion': ubicacion,
        'tipo': 'medico',
      });
    } catch (e) {
      print('Error al guardar médico: $e');
    }
  }
}
