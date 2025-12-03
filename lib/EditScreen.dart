import 'package:flutter/material.dart';

class Editscreen extends StatelessWidget {
  final String? token;
  final int? id;
  final String? title;
  final String? description;

  const Editscreen({
    super.key,
    this.token,
    this.id,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Edit Screen"),
        backgroundColor: Colors.blue,
      ),
      body: Center(child: Text('Edit Screen')),
    );
  }
}
