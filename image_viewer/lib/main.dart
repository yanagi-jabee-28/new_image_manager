import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
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
  List<File> _images = [];
  int _currentIndex = 0;
  String? _folderPath;

  Future<void> _pickFolder() async {
    // Android外部ストレージへのアクセス許可を要求
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      
      // デバイスの外部ストレージディレクトリを取得
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // 画像が保存されている可能性の高いフォルダを探索
        List<String> possiblePaths = [
          '/storage/emulated/0/Pictures',
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Download',
          externalDir.path,
        ];
        
        // 実際に存在するフォルダを選択
        String? selectedDirectory;
        for (String path in possiblePaths) {
          if (await Directory(path).exists()) {
            selectedDirectory = path;
            break;
          }
        }
        
        if (selectedDirectory != null) {
          await _loadImagesFromDirectory(selectedDirectory);
        }
      }
    }
  }
  
  Future<void> _loadImagesFromDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => _isImageFile(f.path))
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    setState(() {
      _images = files;
      _currentIndex = 0;
      _folderPath = dirPath;
    });
  }

  bool _isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.png') ||
        ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.bmp') ||
        ext.endsWith('.webp');
  }

  void _nextImage() {
    if (_images.isNotEmpty && _currentIndex < _images.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _prevImage() {
    if (_images.isNotEmpty && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像ビューア'),
        bottom: _folderPath != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _folderPath!,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickFolder,
            tooltip: 'フォルダを選択',
          ),
        ],
      ),
      body: Center(
        child: _images.isEmpty
            ? const Text('フォルダを選択してください')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.file(
                      _images[_currentIndex],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${_currentIndex + 1} / ${_images.length}\n${_images[_currentIndex].path.split(Platform.pathSeparator).last}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _prevImage,
                        tooltip: '前の画像',
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _nextImage,
                        tooltip: '次の画像',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
