import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class Createtask extends StatelessWidget {
  // accept a nullable token so callers can pass null if no token is available
  final String? token;
  final int? id;
  Createtask({super.key, this.token, this.id});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Widget createTitleField() {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget createDescriptionField() {
    return TextField(
      controller: descriptionController,
      decoration: InputDecoration(
        labelText: 'Task Description',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget createEvalutedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (titleController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task title cannot be empty')),
          );
          return;
        }

        final dataToSend = {
          'id': id?.toString() ?? '',
          'title': titleController.text,
          'description': descriptionController.text,
          'status': 'inprogress',
          'priority': 'high',
            'created_at': DateTime.now().toIso8601String(),
          'due_date': '2026-11-14 16:00:00',
        };

        final response = await http.post(
          Uri.parse('http://localhost:8082/php_task3/uploads.php'),
          headers: {'Authorization': 'Bearer $token'
          , 'Content-Type': 'application/json'},
          body: jsonEncode(dataToSend),
        );

        // For debugging, log the status
        print('CreateTask -> uploads.php status: ${response.statusCode}');
        Navigator.pop(context, true);


      },
      child: Text('Save Task'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task Page"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Text("Please Enter the title of the Task"),
          SizedBox(height: 10),
          createTitleField(),
          SizedBox(height: 20),

          Text("Please Enter the description of the Task"),
          SizedBox(height: 10),
          createDescriptionField(),
          SizedBox(height: 20),
          createEvalutedButton(context),
        ],
      ),
    );
  }
}
