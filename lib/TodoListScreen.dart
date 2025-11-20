import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodolistScreen extends StatelessWidget {
  final String? email;
  final String? token;

  const TodolistScreen({super.key, this.email, this.token});

  Future<List> getTodos() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/php_task3/list.php'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return json['data']['todo_list'];
    } else {
      throw Exception('Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${email ?? "User"}'),
        backgroundColor: Colors.blue,
      ),

      body: FutureBuilder<List>(
        future: getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(list[index]['title']),
                subtitle: Text(list[index]['description']),
                trailing: Text(list[index]['status']),
              );
            },
          );
        },
      ),
    );
  }
}
