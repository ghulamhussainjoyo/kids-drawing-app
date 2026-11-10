import '../../local/artwork/apple.and.books.local.dart';
import '../../models/coloring.artwork.dart';
import 'artwork.repository.dart';

class ArtworkRepositoryImpl implements ArtworkRepository {
  const ArtworkRepositoryImpl();

  @override
  ColoringArtwork appleAndBooks() => const AppleAndBooksArtwork().build();
}
