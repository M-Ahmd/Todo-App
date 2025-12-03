import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Createtask extends StatefulWidget {
  final String? token;
  final int? id;
  const Createtask({super.key, this.token, this.id});

  @override
  State<Createtask> createState() => _CreatetaskState();
}

class _CreatetaskState extends State<Createtask> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  XFile? _selectedImage;
  // 1. متغير عشان نعرف احنا بنحمل الصورة ولا لا
  bool _isImageLoading = false;

  Future<void> _pickImage() async {
    try {
      // أول ما يدوس، شغل اللودينج
      setState(() {
        _isImageLoading = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    } finally {
      // في الآخر خالص (سواء اختار او لا) وقف اللودينج
      setState(() {
        _isImageLoading = false;
      });
    }
  }

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
              SnackBar(content: Text('Task title cannot be empty')));
          return;
        }

        final dataToSend = {
          'id': widget.id?.toString() ?? '',
          'title': titleController.text,
          'description': descriptionController.text,
          'status': 'inprogress',
          'priority': 'high',
          'created_at': DateTime.now().toIso8601String(),
          'due_date': '2026-11-14 16:00:00',
        };

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:8082/php_task3/uploads.php'),
        );
        
        request.headers['Authorization'] = 'Bearer ${widget.token}';
        request.fields['json_data'] = jsonEncode(dataToSend);

        // 2. تعديل الرفع ليناسب الويب والموبايل (Bytes بدل Path)
        // لأن Path بتعمل مشاكل على الكروم
        if (_selectedImage != null) {
          var bytes = await _selectedImage!.readAsBytes();
          request.files.add(
             http.MultipartFile.fromBytes(
              'file', // تأكد ان الاسم هنا زي اللي في الـ PHP (file او image)
              bytes,
              filename: _selectedImage!.name,
            ),
          );
        }

        try {
          var streamResponse = await request.send();
          var response = await http.Response.fromStream(streamResponse);
          
          print('Response status: ${response.statusCode}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            if (context.mounted) Navigator.pop(context, true);
          } else {
            print('Failed: ${response.body}');
             if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: ${response.statusCode}'))
                );
             }
          }
        } catch (e) {
          print('Error occurred: $e');
        }
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
      body: SingleChildScrollView( // عشان الكيبورد
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Please Enter the title of the Task"),
              SizedBox(height: 10),
              createTitleField(),
              SizedBox(height: 20),
        
              Text("Please Enter the description of the Task"),
              SizedBox(height: 10),
              createDescriptionField(),
              SizedBox(height: 20),
        
              // 3. شكل الزرار وهو بيحمل
              Row(
                children: [
                  _isImageLoading 
                  ? const CircularProgressIndicator() // لو بيحمل اظهر دي
                  : ElevatedButton.icon(              // لو خلص اظهر الزرار
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Select Image"),
                    ),
                  
                  const SizedBox(width: 15),
                  
                  if (_selectedImage != null && !_isImageLoading)
                    Expanded(
                      child: Text(
                        _selectedImage!.name,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              createEvalutedButton(context),
            ],
          ),
        ),
      ),
    );
  }
}