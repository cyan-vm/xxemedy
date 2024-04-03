import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
// import '../../xxemedy/lib/common_widget/round_button.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '/view/detail_screen.dart';



class PhotoProgressView extends StatefulWidget {
  const PhotoProgressView({super.key});

  @override
  State<PhotoProgressView> createState() => _PhotoProgressViewState();
}

class _PhotoProgressViewState extends State<PhotoProgressView> {
  // TextEditingController _controllerDescription = TextEditingController();
  // TextEditingController _controllerWeight = TextEditingController();

  GlobalKey<FormState> key = GlobalKey();

  CollectionReference _reference =
  FirebaseFirestore.instance.collection('images');

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    String currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Progress Photo",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "See more",
                              style: TextStyle(
                                color: TColor.gray, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ), // Adjust the height between the Row and the text below
                      Text(
                        currentDate,
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _reference.snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Placeholder while loading
                              }

                              // If there are no images
                              if (snapshot.data == null ||
                                snapshot.data!.docs.isEmpty) {
                                return Text('No images found.');
                              }

                              // Display images
                              // Inside the StreamBuilder where you display images
                              return Row(
                                children: snapshot.data!.docs.map((doc) {
                                    var imageUrl = doc['imageUrl'];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(imageUrl: imageUrl),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: imageUrl, // Unique tag for each image
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: TColor.lightGray,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                }).toList(),
                              );

                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          print('this is a test');
          ImagePicker imagePicker = ImagePicker();
          XFile? file = await imagePicker.pickImage(
            source: ImageSource.gallery);
          print('${file?.path}');

          if (file == null) return;
          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref = storage.ref().child('images/${DateTime.now()}.jpg');
          UploadTask uploadTask = ref.putFile(File(file.path));

          uploadTask.then((res) {
              // Image uploaded successfully, you can get the download URL
              res.ref.getDownloadURL().then((url) {
                  // Now you can save the download URL to Firestore or perform any other operations
                  _reference.add({'imageUrl': url}); // Save the URL to Firestore
              });
          });
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.secondaryG),
            borderRadius: BorderRadius.circular(27.5),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
          ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.photo_camera,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
