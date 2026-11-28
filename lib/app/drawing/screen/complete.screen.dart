import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/complete/complete.action.bar.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/complete/complete.keep.let.go.bar.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/complete/complete.polaroid.card.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/complete/complete.saved.bubble.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/complete/complete.scene.backdrop.dart';
import 'package:kids_drawing_flutter/app/parent_gate/utils/parent.gate.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/button/circle.button.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Polaroid-style finish screen after the green complete check.
class CompleteScreen extends StatefulWidget {
  final DrawingViewModel viewModel;

  const CompleteScreen({super.key, required this.viewModel});

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  Uint8List? previewPng;
  bool loadingPreview = true;
  bool busy = false;
  bool showSavedBubble = false;
  bool confirmingDelete = false;

  DrawingViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  String get dateLabel {
    final millis = viewModel.openRow?.updatedAt;
    DateTime date;
    if (millis == null) {
      date = DateTime.now();
    } else {
      date = DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return DateFormat('MMM d, y').format(date);
  }

  Future<void> _loadPreview() async {
    setState(() {
      loadingPreview = true;
    });
    final bytes = await viewModel.exportPngBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      previewPng = bytes;
      loadingPreview = false;
    });
  }

  Future<void> goHome() async {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void goEdit() {
    Navigator.of(context).pop();
  }

  void confirmDelete() {
    if (busy) {
      return;
    }
    setState(() {
      confirmingDelete = true;
    });
  }

  void keepPaint() {
    setState(() {
      confirmingDelete = false;
    });
  }

  Future<void> letGoPaint() async {
    if (busy) {
      return;
    }
    setState(() {
      busy = true;
    });
    viewModel.clearAll();
    await viewModel.flushSave();
    await _loadPreview();
    if (!mounted) {
      return;
    }
    setState(() {
      busy = false;
      confirmingDelete = false;
    });
  }

  Future<void> downloadPng() async {
    if (busy) {
      return;
    }
    final ok = await ParentGate.request(context);
    if (!ok || !mounted) {
      return;
    }
    setState(() {
      busy = true;
    });
    try {
      final bytes = previewPng ?? await viewModel.exportPngBytes();
      if (bytes == null) {
        return;
      }
      final granted = await Gal.requestPermission();
      if (!granted) {
        return;
      }
      await Gal.putImageBytes(bytes, name: _fileBaseName());
      if (!mounted) {
        return;
      }
      setState(() {
        showSavedBubble = true;
      });
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          showSavedBubble = false;
        });
      }
    } on GalException {
      // Permission denied or save failed — do not show Saved!
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> sharePng() async {
    if (busy) {
      return;
    }
    final ok = await ParentGate.request(context);
    if (!ok || !mounted) {
      return;
    }
    setState(() {
      busy = true;
    });
    try {
      final bytes = previewPng ?? await viewModel.exportPngBytes();
      if (bytes == null) {
        return;
      }
      final temp = await getTemporaryDirectory();
      final file = File(p.join(temp.path, '${_fileBaseName()}.png'));
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out my drawing! 🎨',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  String _fileBaseName() {
    final key = viewModel.openRow?.artworkKey ?? 'artwork';
    return 'kids_drawing_$key';
  }

  Widget bottomBar() {
    if (confirmingDelete) {
      return CompleteKeepLetGoBar(onKeep: keepPaint, onLetGo: letGoPaint);
    }
    return CompleteActionBar(
      onDownload: downloadPng,
      onShare: sharePng,
      onDelete: confirmDelete,
      onEdit: goEdit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CompleteSceneBackdrop.sky,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CompleteSceneBackdrop(),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 8,
                  child: CircleButton(
                    size: 48,
                    color: AppColors.purple,
                    onPressed: goHome,
                    sound: PressSound.exit,
                    image: const Icon(
                      CupertinoIcons.house_fill,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Action slot (~lip CircleButton + padding) stays on cream.
                    const actionSlot = 80.0;
                    final skyHeight = constraints.maxHeight - actionSlot;
                    final maxPolaroidSide = skyHeight * 0.55;
                    return Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: CompletePolaroidCard(
                              loading: loadingPreview,
                              pngBytes: previewPng,
                              dateLabel: dateLabel,
                              maxSide: maxPolaroidSide,
                            ),
                          ),
                        ),
                        bottomBar(),
                      ],
                    );
                  },
                ),
                if (showSavedBubble)
                  const Positioned(
                    right: 28,
                    bottom: 100,
                    child: CompleteSavedBubble(),
                  ),
                if (busy)
                  const ColoredBox(
                    color: Color(0x33000000),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
