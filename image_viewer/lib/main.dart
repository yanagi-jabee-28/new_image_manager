import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '画像ビューア',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ImageViewerPage(),
    );
  }
}

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({super.key});
  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  List<File> images = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
  }

  Future<void> pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        images = result.paths.map((p) => File(p!)).toList();
        currentIndex = 0;
      });
    }
  }

  void showPrev() {
    setState(() {
      currentIndex = (currentIndex - 1 + images.length) % images.length;
    });
  }

  void showNext() {
    setState(() {
      currentIndex = (currentIndex + 1) % images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像ビューア'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: pickImages,
            tooltip: '画像を選択',
          ),
        ],
      ),
      body: images.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: pickImages,
                child: const Text('画像を選択'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      PhotoView(
                        imageProvider: FileImage(images[currentIndex]),
                        minScale: PhotoViewComputedScale.contained * 0.5,
                        maxScale: PhotoViewComputedScale.covered * 3.0,
                        initialScale: PhotoViewComputedScale.contained,
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        heroAttributes: PhotoViewHeroAttributes(
                          tag: images[currentIndex].path,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: showPrev,
                          child: const SizedBox(width: 60),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: showNext,
                          child: const SizedBox(width: 60),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, idx) {
                      return GestureDetector(
                        onTap: () => setState(() => currentIndex = idx),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: idx == currentIndex
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Image.file(
                            images[idx],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${images[currentIndex].path.split(Platform.pathSeparator).last} (${currentIndex + 1}/${images.length})',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
