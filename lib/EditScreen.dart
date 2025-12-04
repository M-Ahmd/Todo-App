import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Editscreen extends StatefulWidget {
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

  String getTitle() {
    return title.toString();
  }

  @override
  State<Editscreen> createState() => _EditscreenState();
}

class _EditscreenState extends State<Editscreen> {
  //final TextEditingController titleController = TextEditingController(text: widget.getTitle());
  //final TextEditingController descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isImageLoading = false;

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget createTitleField() {
    return TextField(
      decoration: InputDecoration(
        labelText: "Task Title",
        hintText: "Edit the title",
      ),
      controller: titleController,
    );
  }

  Widget createDescriptionField() {
    return TextField(
      decoration: InputDecoration(
        labelText: "Task Descriptio",
        hintText: "Edit the description",
      ),
      controller: descriptionController,
    );
  }

  Future<void> Update() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task title cannot be empty')));
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
      Uri.parse("http://localhost:8082/php_task3/uploads.php"),
    );
    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.fields['json_data'] = jsonEncode(dataToSend);

    if (_selectedImage != null) {
      var bytes = await _selectedImage!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: _selectedImage!.name,
        ),
      );
    }
    try {
      var streamResponse = await request.send();
      var response = await streamResponse.stream.bytesToString();
      print("PHP ERROR: $response");
      if (streamResponse.statusCode == 200 ||
          streamResponse.statusCode == 201) {
        if (context.mounted) Navigator.pop(context, true);
        print('response is ${streamResponse.statusCode}');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${streamResponse.statusCode}')),
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteToDo() async {
    final request = await http.post(
      Uri.parse("http://localhost:8082/php_task3/delete.php"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({"id": widget.id}),
    );
    if (request.statusCode == 200 || request.statusCode == 201) {
      Navigator.pop(context, true);
    }
    else
    {
      throw Exception('Failed to delete task');
    }
  }

  Widget createSaveButton() {
    return ElevatedButton(onPressed: Update, child: Text("Save the data"));
  }

  Widget createDeleteButton() {
    return ElevatedButton(
      onPressed: deleteToDo,
      child: Text("Delete this todo"),
    );
  }

  Future<void> _pickImage() async {
    try {
      //setState
      setState(() {
        _isImageLoading = true;
      });
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        //setState
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      //setState
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Edit Screen"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          createTitleField(),
          SizedBox(height: 20),
          createDescriptionField(),
          SizedBox(height: 20),

          Row(
            children: [
              _isImageLoading
                  ? const CircularProgressIndicator() // لو بيحمل اظهر دي
                  : ElevatedButton.icon(
                      // لو خلص اظهر الزرار
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
          SizedBox(height: 20),

          createSaveButton(),

          SizedBox(height: 20),
          createDeleteButton(),
        ],
      ),
    );
  }
}
