import 'package:flutter/material.dart';
import 'package:image_editing/pages/edit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? imageFile; // объект класса File, представляющий выбранное изображение

  void _showImageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Выберите, откуда загрузить фото:',
              style: TextStyle(fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromGallery(context);
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      Text(
                        'Галерея',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromCamera(context);
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      Text(
                        'Камера',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  /// Get from gallery
  _getFromGallery(BuildContext context) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      Future.delayed(const Duration(seconds: 0)).then(
        (value) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditScreen(
                    selectedImage: imageFile!.path,
                  )),
        ),
      );
    }
  }

  /// Get from camera
  _getFromCamera(BuildContext context) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      Future.delayed(const Duration(seconds: 0)).then(
        (value) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditScreen(
                    selectedImage: imageFile!.path,
                  )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Мой фоторедактор'),
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: Colors.white,
                  shadowColor: Colors.black,
                  shape: const CircleBorder(),
                  minimumSize: const Size(100, 100),
                  side: const BorderSide(width: 5, color: Colors.black),
                ),
                onPressed: () {
                  _showImageDialog(context);
                },
                child: const Icon(
                  Icons.add,
                  size: 80,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
