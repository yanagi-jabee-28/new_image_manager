import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart'; // 追加
import 'package:logging/logging.dart';

final _logger = Logger('ImageViewer');

void main() {
  // ログ出力の設定
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // printの代わりにここで出力
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const MyApp());
}

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
  final ScrollController _thumbController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    _thumbController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
  }

  Future<void> pickFolderImages() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    _logger.info('selectedDirectory: $selectedDirectory');
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      final files = dir
          .listSync()
          .whereType<File>()
          .where(
            (f) =>
                f.path.toLowerCase().endsWith('.jpg') ||
                f.path.toLowerCase().endsWith('.jpeg') ||
                f.path.toLowerCase().endsWith('.png') ||
                f.path.toLowerCase().endsWith('.gif') ||
                f.path.toLowerCase().endsWith('.webp') ||
                f.path.toLowerCase().endsWith('.bmp'),
          )
          .toList();
      _logger.info('画像ファイル数: ${files.length}');

      // ナチュラルソートで並べ替え
      files.sort(
        (a, b) => compareNatural(
          a.path.split(Platform.pathSeparator).last.toLowerCase(),
          b.path.split(Platform.pathSeparator).last.toLowerCase(),
        ),
      );

      if (files.isNotEmpty) {
        setState(() {
          images = files;
          currentIndex = 0;
        });
      }
    }
  }

  void updateCurrentIndex(int idx) {
    _logger.info('updateCurrentIndex: $idx, file: ${images[idx].path}');
    setState(() {
      currentIndex = idx;
    });
    // サムネイルを中央付近にスクロール
    _thumbController.animateTo(
      (idx * 96.0).toDouble(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void showPrev() {
    _logger.info(
      'showPrev: $currentIndex → ${(currentIndex - 1 + images.length) % images.length}',
    );
    if (images.isEmpty) return;
    int idx = (currentIndex - 1 + images.length) % images.length;
    updateCurrentIndex(idx);
  }

  void showNext() {
    _logger.info(
      'showNext: $currentIndex → ${(currentIndex + 1) % images.length}',
    );
    if (images.isEmpty) return;
    int idx = (currentIndex + 1) % images.length;
    updateCurrentIndex(idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像ビューア'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: pickFolderImages,
            tooltip: 'フォルダを選択',
          ),
        ],
      ),
      body: images.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: pickFolderImages,
                child: const Text('フォルダを選択'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < 0) {
                            // 左スワイプ→次へ
                            showNext();
                          } else if (details.primaryVelocity! > 0) {
                            // 右スワイプ→前へ
                            showPrev();
                          }
                        }
                      },
                      child: Center(
                        child: Image.file(
                          images[currentIndex],
                          fit: BoxFit.contain,
                          height: MediaQuery.of(context).size.height - 200,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 100,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _thumbController, // ← 追加
                    child: ListView.builder(
                      controller: _thumbController, // ← 追加
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, idx) {
                        return GestureDetector(
                          onTap: () => updateCurrentIndex(idx),
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
