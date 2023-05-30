import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SaveImageScreen extends StatefulWidget {
  final List? arguments;

  const SaveImageScreen({super.key, this.arguments});

  @override
  _SaveImageScreenState createState() => _SaveImageScreenState();
}

class _SaveImageScreenState extends State<SaveImageScreen> {
  File? image;
  bool? savedImage;

  @override
  void initState() {
    super.initState();
    image = widget.arguments![0];
    savedImage = false;
  }

  Future saveImage() async {
    await GallerySaver.saveImage(image!.path, albumName: "Мой фоторедактор");
    setState(() {
      savedImage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ClipRRect(
              child: Container(
                color: Theme.of(context).hintColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.9,
                child: PhotoView(
                  imageProvider: FileImage(image!),
                  backgroundDecoration: BoxDecoration(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            //
            const Spacer(),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                      disabledElevation: 0,
                      heroTag: "Сохранить",
                      icon: const Icon(Icons.save),
                      label: savedImage!
                          ? const Text(
                              "Сохранено",
                              style: TextStyle(fontSize: 20),
                            )
                          : const Text(
                              "Сохранить",
                              style: TextStyle(fontSize: 20),
                            ),
                      backgroundColor: savedImage!
                          ? Colors.blueGrey
                          : Theme.of(context).primaryColor,
                      onPressed: savedImage!
                          ? null
                          : () {
                              saveImage();
                            }),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
