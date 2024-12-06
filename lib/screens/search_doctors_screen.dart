import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusquedaMedicosScreen extends StatefulWidget {
  @override
  _BusquedaMedicosScreenState createState() => _BusquedaMedicosScreenState();
}

class _BusquedaMedicosScreenState extends State<BusquedaMedicosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _resultadosBusqueda = [];

  Future<void> _buscarMedicos(String query) async {
    final medicosSnapshot = await _firestore.collection('medicos').get();

    final resultados = medicosSnapshot.docs
        .where((doc) =>
            doc['nombre']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            doc['especialidad']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            doc['ubicacion']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .map((doc) => {
              'id': doc.id,
              'nombre': doc['nombre'],
              'especialidad': doc['especialidad'],
              'ubicacion': doc['ubicacion'],
            })
        .toList();

    setState(() {
      _resultadosBusqueda = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Médicos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, especialidad o ubicación',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarMedicos(_searchController.text),
                ),
              ),
              onSubmitted: (value) => _buscarMedicos(value),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _resultadosBusqueda.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron resultados.',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _resultadosBusqueda.length,
                      itemBuilder: (context, index) {
                        final medico = _resultadosBusqueda[index];
                        return ListTile(
                          title: Text(medico['nombre']),
                          subtitle: Text(
                              'Especialidad: ${medico['especialidad']}\nUbicación: ${medico['ubicacion']}'),
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
