import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Postulaciones'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'En Revision'),
              Tab(text: 'Contactado'),
              Tab(text: 'Descartado'),
              Tab(text: 'Cerrada'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('En construccion - En Revision')),
            Center(child: Text('En construccion - Contactado')),
            Center(child: Text('En construccion - Descartado')),
            Center(child: Text('En construccion - Cerrada')),
          ],
        ),
      ),
    );
  }
}