import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_culture_app/services/cloudinary_service.dart';

class RoutineScreen extends StatefulWidget {
  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final List<Map<String, String>> _routineSteps = [
    {'title': 'Cleanser', 'subtitle': 'Cetaphil Gentle Skin Cleanser',},
    {'title': 'Toner', 'subtitle': 'Thayers Witch Hazel Toner',},
    {'title': 'Moisturizer', 'subtitle': "Kiehl's Ultra Facial Cream",},
    {'title': 'Sunscreen', 'subtitle': 'Supergoop Unseen Sunscreen SPF 40',},
    {'title': 'Lip Balm', 'subtitle': 'Glossier Birthday Balm Dotcom',},
  ];
  final Map<String, bool> _selectedSteps = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    File? _selectedImage;
  String? _uploadedImageUrl;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    for (var step in _routineSteps) {
      _selectedSteps[step['title']!] = false;
    }
  }

    Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadToCloudinary(_selectedImage!);
    }
  }

  Future<void> _uploadToCloudinary(File imageFile) async {
    String? imageUrl = await _cloudinaryService.uploadImage(imageFile);
    if (imageUrl != null) {
      setState(() {
        _uploadedImageUrl = imageUrl;
      });
    }
  }

  Future<void> _recordRoutine() async {
    User? user = _auth.currentUser;
    if (user != null) {
      bool allStepsSelected = _selectedSteps.values.every((isSelected) => isSelected);
      if (allStepsSelected) {
        await _firestore.collection('users').doc(user.uid).set(
          {
            'streak': FieldValue.increment(1),
            'lastUpdated': DateTime.now(),
            'routine': _selectedSteps, // Store all skincare steps
          },
          SetOptions(merge: true),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Routine recorded successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please complete all steps!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Skincare'),
        backgroundColor: Colors.pink[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _routineSteps.length,
              itemBuilder: (context, index) {
                var step = _routineSteps[index];
                return ListTile(
                  leading: Checkbox(
                    value: _selectedSteps[step['title']],
                    onChanged: (value) {
                      setState(() {
                        _selectedSteps[step['title']!] = value!;
                      });
                    },
                    activeColor: Colors.pinkAccent,
                  ),
                  title: Text(
                    step['title']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(step['subtitle']!),
                );
              },
            ),
          ),
                SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: Text('Upload Image'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade100),
                          ),
                          if (_uploadedImageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Image.network(_uploadedImageUrl!, height: 100),
                            ),
                        ],
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordRoutine,
        child: Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}