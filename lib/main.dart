import 'package:flutter/material.dart';
import 'package:image_editing/pages/home.dart';
import 'package:image_editing/pages/edit.dart';
import 'package:image_editing/pages/save.dart';

void main() =>
    runApp(MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const Home(),
          '/edit': (context) =>
          const EditScreen(
            selectedImage: '',
          ),
          '/save': (context) => const SaveImageScreen()
        },
        theme: ThemeData(
          primaryColor: Colors.black,
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Colors.black),
        ),
        debugShowCheckedModeBanner: false,
    ));
