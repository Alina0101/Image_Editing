import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart' hide ImageSource;
import 'package:image_editing/pages/save.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key, required this.selectedImage}) : super(key: key);

  final String selectedImage;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  double sat = 1;
  double bright = 0;
  double con = 1;

  final defaultColorMatrix = const <double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  List<double> calculateSaturationMatrix(double saturation) {
    final m = List<double>.from(defaultColorMatrix);
    final invSat = 1 - saturation;
    final R = 0.213 * invSat;
    final G = 0.715 * invSat;
    final B = 0.072 * invSat;

    m[0] = R + saturation;
    m[1] = G;
    m[2] = B;
    m[5] = R;
    m[6] = G + saturation;
    m[7] = B;
    m[10] = R;
    m[11] = G;
    m[12] = B + saturation;

    return m;
  }

  List<double> calculateContrastMatrix(double contrast) {
    final m = List<double>.from(defaultColorMatrix);
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return m;
  }

  late File image;

  @override
  void initState() {
    super.initState();
    image = File(widget.selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
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
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.settings_backup_restore,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  sat = 1;
                  bright = 0;
                  con = 1;
                  editorKey.currentState?.reset();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, size: 30),
              onPressed: () async {
                await edit();
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(children: [
              SizedBox(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: buildImage(),
                ),
              ),
            ]),
            Row(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Spacer(flex: 1),
                          buildSaturationSlider(),
                          const Spacer(flex: 1),
                          _buildBrightnessSlider(),
                          const Spacer(flex: 1),
                          _buildContrastSlider(),
                          const Spacer(flex: 8),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNB(),
    );
  }

  Widget buildImage() {
    // Применение матрицы контрастности к изображению
    final contrastFilter = ColorFilter.matrix(calculateContrastMatrix(con));
    // Применение матрицы насыщенности к изображению
    final saturationFilter = ColorFilter.matrix(calculateSaturationMatrix(sat));
    // Создание виджета ExtendedImage с применением фильтров и других настроек
    return ColorFiltered(
      colorFilter: contrastFilter,
      child: ColorFiltered(
        colorFilter: saturationFilter,
        child: ExtendedImage(
          // Установка цвета и режима смешивания
          color: bright > 0
              ? Colors.white.withOpacity(bright)
              : Colors.black.withOpacity(-bright),
          colorBlendMode: bright > 0 ? BlendMode.lighten : BlendMode.darken,
          // Передача изображения с использованием ExtendedFileImageProvider
          image: ExtendedFileImageProvider(image, cacheRawData: true),
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          extendedImageEditorKey: editorKey,
          mode: ExtendedImageMode.editor,
          // Установка режима масштабирования изображения
          fit: BoxFit.contain,
          // Настройка конфигурации редактора изображений
          initEditorConfigHandler: (state) => EditorConfig(
            maxScale: 8.0,
            cropRectPadding: const EdgeInsets.all(20.0),
            hitTestSize: 10.0,
            cornerColor: Colors.black,
            cornerSize: const Size(30.0, 4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNB() {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).primaryColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(
              Icons.flip,
              color: Colors.white,
            ),
            label: ""),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.rotate_left,
              color: Colors.white,
            ),
            label: ""),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.rotate_right,
              color: Colors.white,
            ),
            label: ""),
      ],
      onTap: (int index) {
        switch (index) {
          case 0:
            editorKey.currentState!.flip();
            break;
          case 1:
            editorKey.currentState!.rotate(right: false);
            break;
          case 2:
            editorKey.currentState!.rotate(right: true);
            break;
        }
      },
      currentIndex: 0,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).primaryColor,
    );
  }

  Future<void> edit() async {
    final ExtendedImageEditorState? state = editorKey.currentState;
    final Rect? rect = state?.getCropRect();
    final double radian = state!.editAction!.rotateAngle;
    final bool flipHorizontal = state.editAction!.flipY;
    final bool flipVertical = state.editAction!.flipX;
    final Uint8List img = state.rawImageData;
    final EditActionDetails? action = state.editAction;

    final ImageEditorOption option = ImageEditorOption();

    option.addOption(ClipOption.fromRect(rect!));
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    if (action!.hasRotateAngle) {
      option.addOption(RotateOption(radian.toInt()));
    }

    option.addOption(ColorOption.saturation(sat));
    option.addOption(ColorOption.brightness(bright + 1));
    option.addOption(ColorOption.contrast(con));

    option.outputFormat = const OutputFormat.jpeg(100);

    final Uint8List? resultImage = await ImageEditor.editImage(
      imageEditorOption: option,
      image: img,
    );

    image.writeAsBytesSync(resultImage!);

    Future.delayed(const Duration(seconds: 0)).then(
      (value) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SaveImageScreen(
                  arguments: [image],
                )),
      ),
    );
  }

  Widget buildSaturationSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.brush,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Насыщенность",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        Expanded(
          child: Slider(
            label: 'sat : ${sat.toStringAsFixed(2)}',
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveColor: Colors.blueGrey,
            onChanged: (double value) {
              setState(() {
                sat = value;
              });
            },
            divisions: 50,
            value: sat,
            min: 0,
            max: 4,
          ),
        ),
        Padding(
          padding:
          EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(sat.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildBrightnessSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.brightness_4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Яркость",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Slider(
            label: bright.toStringAsFixed(2),
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveColor: Colors.blueGrey,
            onChanged: (double value) {
              setState(() {
                bright = value;
              });
            },
            divisions: 50,
            value: bright,
            min: -1,
            max: 1,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(bright.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildContrastSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.color_lens,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Констраст",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Slider(
            label: 'con : ${con.toStringAsFixed(2)}',
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveColor: Colors.blueGrey,
            onChanged: (double value) {
              setState(() {
                con = value;
              });
            },
            divisions: 50,
            value: con,
            min: 0,
            max: 3,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(con.toStringAsFixed(2)),
        ),
      ],
    );
  }
}
