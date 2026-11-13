import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/drawing/screen/drawing.screen.dart.dart';
import 'package:kids_drawing_flutter/data/repositories/gallery/gallery.repository.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';
import 'package:kids_drawing_flutter/types/gellery/gallery.model.dart';

class GalleryViewModel extends ChangeNotifier {
  List<GalleryModel> galleryList = [];
  final DrawingViewModel drawingViewModel = DrawingViewModel();
  final GalleryRepository galleryRepository = GalleryRepository();

  GalleryViewModel() {
    galleryList = galleryRepository.getGalleryList();
  }

  List<GalleryModel> getGalleryList() {
    return galleryRepository.getGalleryList();
  }

  void onGalleryPressed(BuildContext context, String id) {
    final gallery = galleryList.firstWhere((gallery) => gallery.id == id);
    drawingViewModel.selectArtwork(gallery.id);
    drawingViewModel.openSelectedArtwork();
    final route = CupertinoPageRoute(
      builder: (context) => const DrawingScreen(),
    );
    Navigator.push(context, route);
  }
}
