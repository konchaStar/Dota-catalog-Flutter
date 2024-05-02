class CardItem {
  final String id;
  final String name;
  final String price;
  final String hero;

  final List<String> images;
  int currentIndex;

  CardItem({
    this.currentIndex = 0,
    required this.name,
    required this.price,
    required this.images,
    required this.hero,
    required this.id,
  });
}