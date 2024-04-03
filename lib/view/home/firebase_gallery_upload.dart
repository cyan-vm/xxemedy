import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';


class GalleryView extends StatefulWidget {
  const GalleryView({Key? key}) : super(key: key);

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  TextEditingController _controllerDescription = TextEditingController();
  TextEditingController _controllerWeight = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('progress_photos');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add an item'),
      ),
      body: Center(
        child: Column(
        children: [Text("data"), Text("nmmmmmmmmms")],
      ),
      )
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: _controllerDescription,
                decoration:
                    InputDecoration(hintText: 'Enter the description of the item'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item description';
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _controllerWeight,
                decoration:
                    InputDecoration(hintText: 'Enter the weight of the item'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item weight';
                  }

                  return null;
                },
              ),
              IconButton(
                onPressed: () async {
                  ImagePicker imagePicker = ImagePicker();
                  XFile? file = await imagePicker.pickImage(
                      source: ImageSource.gallery);
                  print('${file?.path}');

                  if (file == null) return;

                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  Reference referenceRoot =
                      FirebaseStorage.instance.ref();
                  Reference referenceDirImages =
                      referenceRoot.child('images');

                  Reference referenceImageToUpload =
                      referenceDirImages.child(uniqueFileName);

                  try {
                    await referenceImageToUpload
                        .putFile(File(file!.path));
                    imageUrl = await referenceImageToUpload.getDownloadURL();
                  } catch (error) {
                    // Handle error
                  }
                },
                icon: Icon(Icons.camera_alt),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (imageUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please upload an image')));

                    return;
                  }

                  if (key.currentState!.validate()) {
                    String itemDescription = _controllerDescription.text;
                    String itemWeight = _controllerWeight.text;
                    String uploadMonth =
                        DateFormat('yyyy-MM').format(DateTime.now());

                    Map<String, String> dataToSend = {
                      'description': itemDescription,
                      'weight': itemWeight,
                      'image': imageUrl,
                      'uploadMonth': uploadMonth,
                    };

                    _reference.add(dataToSend);
                  }
                },
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

