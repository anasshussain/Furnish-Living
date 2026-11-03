/// The silhouette used to draw a product (see FurniturePainter).
enum FurnitureKind {
  tubChair('Armchair'),
  bubbleChair('Cloud chair'),
  wingChair('Wing chair'),
  shellChair('Shell chair'),
  sofa('Sofa'),
  loveseat('Loveseat'),
  diningTable('Dining table'),
  coffeeTable('Coffee table'),
  barStool('Bar stool'),
  kitchenIsland('Kitchen island'),
  bed('Bed'),
  floorLamp('Floor lamp'),
  bookshelf('Bookshelf');

  const FurnitureKind(this.label);

  final String label;
}
