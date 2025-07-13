import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart'; // 追加
import 'package:logging/logging.dart';
import 'package:photo_view/photo_view.dart';

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
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _thumbController = ScrollController();
  bool _isUserSelecting = false; // ★追加

  @override
  void initState() {
    super.initState();
    // 下記2行だけ残す
    _requestPermission();
    _mainScrollController.addListener(_onMainScroll);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ 画像権限
      final photos = Permission.photos;
      final storage = Permission.storage;
      PermissionStatus status;

      // まずphotos権限をリクエスト（Android 13+のみ有効）
      status = await photos.request();
      if (status.isGranted) return true;

      // それ以外はstorage権限
      status = await storage.request();
      if (status.isGranted) return true;

      // 拒否された場合は設定画面へ誘導
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  Future<void> pickFolderImages() async {
    bool granted = await _requestPermission();
    if (!granted) {
      _logger.warning('権限がないため画像を表示できません');
      return;
    }
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

      // ナチュラルソート（拡張子を除いたファイル名で比較、ゼロ埋めも考慮）
      files.sort((a, b) {
        String nameA = a.path.split(Platform.pathSeparator).last;
        String nameB = b.path.split(Platform.pathSeparator).last;
        String baseA = nameA.contains('.')
            ? nameA.substring(0, nameA.lastIndexOf('.'))
            : nameA;
        String baseB = nameB.contains('.')
            ? nameB.substring(0, nameB.lastIndexOf('.'))
            : nameB;
        // ナチュラルソート
        int cmp = compareNatural(baseA.toLowerCase(), baseB.toLowerCase());
        if (cmp != 0) return cmp;
        // ファイル名が同じ場合は拡張子で比較
        return nameA.compareTo(nameB);
      });

      if (files.isNotEmpty) {
        setState(() {
          images = files; // File型リストに切り替え
          currentIndex = 0;
        });
      }
    }
  }

  // メイン画像のスクロール位置からcurrentIndexを更新
  void _onMainScroll() {
    if (_isUserSelecting) return; // ★ユーザー選択中は自動スクロールも完全に抑制
    if (images.isEmpty) return;

    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    double imageWidth = isPortrait ? screenSize.width : screenSize.height - 150;

    double scrollCenter =
        _mainScrollController.offset + MediaQuery.of(context).size.width / 2;
    int idx = (scrollCenter ~/ imageWidth).clamp(0, images.length - 1);
    if (idx != currentIndex) {
      setState(() {
        currentIndex = idx;
      });
      // ★ここでサムネイルも追従させたい場合のみanimateToを呼ぶ
      // だが_isUserSelecting中は呼ばないので、サムネイル選択時は追従しない
      if (!_isUserSelecting) {
        final isPortrait =
            MediaQuery.of(context).size.height >
            MediaQuery.of(context).size.width;
        final thumbnailSize = isPortrait ? 90.0 : 75.0;
        final thumbnailSpacing = thumbnailSize + 16.0; // サムネイルサイズ + margin

        _thumbController.animateTo(
          (idx * thumbnailSpacing).toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  Future<void> updateCurrentIndex(int idx) async {
    _isUserSelecting = true; // ★ユーザー操作開始
    _mainScrollController.removeListener(_onMainScroll);
    setState(() {
      currentIndex = idx;
    });

    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    double imageWidth = isPortrait ? screenSize.width : screenSize.height - 150;

    await _mainScrollController.animateTo(
      (idx * imageWidth),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    if (!mounted) return;
    // サムネイルリストの自動スクロールは行わない
    _mainScrollController.addListener(_onMainScroll);
    _isUserSelecting = false; // ★ユーザー操作終了
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
                    child: ListView.builder(
                      controller: _mainScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, idx) {
                        final screenSize = MediaQuery.of(context).size;
                        final isPortrait = screenSize.height > screenSize.width;

                        // スマホ画面サイズに応じた画像サイズを計算
                        double imageWidth, imageHeight;
                        if (isPortrait) {
                          // 縦画面：幅をベースに、サムネイルエリアとアプリバーを考慮
                          imageWidth = screenSize.width;
                          imageHeight =
                              screenSize.height -
                              200; // AppBar + サムネイル + テキスト領域
                        } else {
                          // 横画面：高さをベースに調整
                          imageHeight = screenSize.height - 150;
                          imageWidth = imageHeight;
                        }

                        return Center(
                          child: SizedBox(
                            width: imageWidth,
                            height: imageHeight,
                            child: PhotoView.customChild(
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 3.0,
                              backgroundDecoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              enableRotation: false,
                              child: Image.file(
                                images[idx],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height:
                      MediaQuery.of(context).size.height >
                          MediaQuery.of(context).size.width
                      ? 120
                      : 100, // 縦画面時は少し大きく
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _thumbController,
                    child: ListView.builder(
                      controller: _thumbController,
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, idx) {
                        final isPortrait =
                            MediaQuery.of(context).size.height >
                            MediaQuery.of(context).size.width;
                        final thumbnailSize = isPortrait
                            ? 90.0
                            : 75.0; // 縦画面時はサムネイルを大きく

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
                              width: thumbnailSize,
                              height: thumbnailSize,
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
