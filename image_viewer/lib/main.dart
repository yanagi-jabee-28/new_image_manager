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
  // image_list.txtから生成したassets画像リスト
  final List<String> assetImages = [
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (1).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (10).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (100).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (101).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (102).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (103).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (104).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (105).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (106).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (107).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (108).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (109).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (11).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (110).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (111).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (112).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (113).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (114).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (115).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (116).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (117).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (118).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (119).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (12).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (120).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (121).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (122).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (123).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (124).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (125).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (126).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (127).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (128).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (129).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (13).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (130).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (131).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (132).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (133).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (134).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (135).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (136).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (137).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (138).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (139).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (14).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (140).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (141).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (142).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (143).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (144).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (145).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (146).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (147).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (148).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (149).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (15).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (150).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (151).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (152).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (153).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (154).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (155).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (156).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (157).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (158).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (159).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (16).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (160).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (161).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (162).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (163).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (164).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (165).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (166).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (167).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (168).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (169).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (17).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (170).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (171).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (172).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (173).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (174).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (175).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (176).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (177).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (178).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (179).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (18).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (180).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (181).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (182).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (183).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (184).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (185).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (186).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (187).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (188).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (189).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (19).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (190).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (191).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (192).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (193).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (194).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (195).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (196).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (197).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (198).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (199).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (2).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (20).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (200).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (201).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (202).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (203).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (204).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (205).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (206).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (207).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (208).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (209).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (21).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (22).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (23).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (24).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (25).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (26).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (27).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (28).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (29).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (3).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (30).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (31).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (32).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (33).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (34).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (35).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (36).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (37).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (38).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (39).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (4).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (40).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (41).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (42).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (43).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (44).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (45).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (46).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (47).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (48).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (49).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (5).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (50).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (51).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (52).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (53).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (54).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (55).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (56).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (57).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (58).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (59).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (6).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (60).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (61).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (62).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (63).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (64).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (65).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (66).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (67).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (68).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (69).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (7).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (70).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (71).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (72).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (73).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (74).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (75).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (76).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (77).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (78).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (79).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (8).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (80).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (81).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (82).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (83).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (84).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (85).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (86).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (87).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (88).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (89).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (9).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (90).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (91).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (92).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (93).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (94).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (95).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (96).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (97).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (98).png",
    "assets/images/nogizaka46_inoue_nagi_photobook/image_nagi (99).png",
  ];
  List<dynamic> images = [];
  int currentIndex = 0;
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _thumbController = ScrollController();
  bool _isUserSelecting = false; // ★追加

  @override
  void initState() {
    super.initState();
    // ナチュラルソートでassets画像を並べ替え
    final sortedAssets = List<String>.from(assetImages)
      ..sort(
        (a, b) => compareNatural(
          a.split('/').last.toLowerCase(),
          b.split('/').last.toLowerCase(),
        ),
      );
    images = sortedAssets;
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

      // ナチュラルソートで並べ替え
      files.sort(
        (a, b) => compareNatural(
          a.path.split(Platform.pathSeparator).last.toLowerCase(),
          b.path.split(Platform.pathSeparator).last.toLowerCase(),
        ),
      );

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
    double imageWidth = MediaQuery.of(context).size.height - 200;
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
        _thumbController.animateTo(
          (idx * 96.0).toDouble(),
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
    double imageWidth = MediaQuery.of(context).size.height - 200;
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
                        double imageHeight =
                            MediaQuery.of(context).size.height - 200;
                        return Center(
                          child: SizedBox(
                            width: imageHeight, // 横幅も高さと同じ値で確保
                            height: imageHeight,
                            child: PhotoView.customChild(
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 3.0,
                              backgroundDecoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              enableRotation: false,
                              child: images[idx] is String
                                  ? Image.asset(
                                      images[idx],
                                      fit: BoxFit.contain,
                                    )
                                  : Image.file(
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
                  height: 100,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _thumbController,
                    child: ListView.builder(
                      controller: _thumbController,
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
                            child: images[idx] is String
                                ? Image.asset(
                                    images[idx],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
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
                    '${images[currentIndex] is String ? (images[currentIndex] as String).split('/').last : (images[currentIndex] as File).path.split(Platform.pathSeparator).last} (${currentIndex + 1}/${images.length})',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
