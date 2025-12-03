import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CreateTask.dart';
import 'EditScreen.dart';

class Todolistscreen extends StatefulWidget {
  final String? email;
  final String? token;

  const Todolistscreen({super.key, this.email, this.token});

  @override
  State<Todolistscreen> createState() => _TodolistscreenState();
}

class _TodolistscreenState extends State<Todolistscreen> {
  late Future<List> _todoListFuture;

  @override
  void initState() {
    super.initState();
    _todoListFuture = getTodos();
  }

  Future<List> getTodos() async {
    final response = await http.get(
      Uri.parse('http://localhost:8082/php_task3/list.php'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      }, //$widget.token wrong
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      print(response.body);
      return json['data']['todo_list'];
    } else {
      throw Exception('Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    int lastId = 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${widget.email ?? "User"}'),
        backgroundColor: Colors.blue,
      ),

      body: FutureBuilder<List>(
        future: _todoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];
          lastId = list.length + 1;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(list[index]['title']),
                subtitle: Text(list[index]['description']),
                trailing: Text(list[index]['status']),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Editscreen(
                        token: widget.token,
                        id: int.parse(list[index]['id'].toString()),
                        title: list[index]['title'],
                        description: list[index]['description'],
                      ),
                    ),
                  ),
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Createtask(token: widget.token, id: lastId),
            ),
          );

          if (result == true) {
            setState(() {
              _todoListFuture = getTodos();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
