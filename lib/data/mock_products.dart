import 'package:flutter/material.dart';

import 'models/furniture_kind.dart';
import 'models/product.dart';
import 'models/product_category.dart';

const _sage = ProductColor('Sage', Color(0xFF5E8B4F));
const _forest = ProductColor('Forest', Color(0xFF3F6B3A));
const _sand = ProductColor('Sand', Color(0xFFD8C3A5));
const _cream = ProductColor('Cream', Color(0xFFEFE7DA));
const _stone = ProductColor('Stone', Color(0xFF9A9A94));
const _charcoal = ProductColor('Charcoal', Color(0xFF3A3A3C));
const _sky = ProductColor('Sky', Color(0xFF8DB7DD));
const _navy = ProductColor('Navy', Color(0xFF2F4B8A));
const _blush = ProductColor('Blush', Color(0xFFE0A9AE));
const _terracotta = ProductColor('Terracotta', Color(0xFFD9825B));
const _mustard = ProductColor('Mustard', Color(0xFFD9A93E));
const _oak = ProductColor('Oak', Color(0xFFC89B6A));
const _walnut = ProductColor('Walnut', Color(0xFF7A5237));
const _ash = ProductColor('Ash', Color(0xFFDCC8A8));
const _black = ProductColor('Black', Color(0xFF1E1E1E));
const _white = ProductColor('White', Color(0xFFF3F1EC));

/// Local catalogue used by [ProductRepository]. Swap the repository for a
/// network/Supabase implementation to load real data.
const List<Product> kProducts = [
  // ---- Chairs -------------------------------------------------------------
  Product(
    id: 'soft-element-jack',
    name: 'Soft Element Jack',
    category: ProductCategory.chairs,
    kind: FurnitureKind.wingChair,
    priceCents: 5750,
    colors: [_sky, _sand, _blush, _navy, _mustard],
    description:
        'A tufted wingback with a soft, rounded silhouette. Deep seat padding '
        'and tapered legs make it a comfortable accent for reading corners and '
        'living rooms.',
    rating: 4.6,
    reviews: 128,
  ),
  Product(
    id: 'leset-galant',
    name: 'Leset Galant',
    category: ProductCategory.chairs,
    kind: FurnitureKind.bubbleChair,
    priceCents: 6400,
    colors: [_sage, _cream, _terracotta, _mustard, _stone],
    description:
        'The inspiration for the design of this chair comes from the '
        'industrial style of the first half of the last century, which is '
        'complemented by the most modern features.',
    rating: 4.8,
    reviews: 212,
  ),
  Product(
    id: 'chester-chair',
    name: 'Chester Chair',
    category: ProductCategory.chairs,
    kind: FurnitureKind.tubChair,
    priceCents: 6100,
    colors: [_sand, _charcoal, _sage, _blush, _navy],
    description:
        'A rounded tub chair wrapped in a warm woven fabric. The enveloping '
        'back keeps you supported while the low profile fits small rooms.',
    rating: 4.5,
    reviews: 96,
  ),
  Product(
    id: 'avrora-chair',
    name: 'Avrora Chair',
    category: ProductCategory.chairs,
    kind: FurnitureKind.tubChair,
    priceCents: 7400,
    colors: [_blush, _cream, _terracotta, _forest, _navy],
    description:
        'A swivel-style lounge chair with a sculpted shell and a plush seat '
        'cushion. A statement piece for bedrooms, studios and reading nooks.',
    rating: 4.7,
    reviews: 154,
  ),
  Product(
    id: 'ora-shell-chair',
    name: 'Ora Shell Chair',
    category: ProductCategory.chairs,
    kind: FurnitureKind.shellChair,
    priceCents: 6900,
    colors: [_cream, _mustard, _sage, _blush, _charcoal],
    description:
        'A fan-shaped back with soft ribbing and solid wood legs. Light enough '
        'to move around, elegant enough to stay put.',
    rating: 4.4,
    reviews: 73,
  ),

  // ---- Sofas --------------------------------------------------------------
  Product(
    id: 'nordic-haven-sofa',
    name: 'Nordic Haven Sofa',
    category: ProductCategory.sofas,
    kind: FurnitureKind.sofa,
    priceCents: 38900,
    colors: [_stone, _cream, _navy, _forest, _terracotta],
    description:
        'A generous three-seater with clean lines, deep cushions and '
        'removable covers. Built for long movie nights and relaxed weekends.',
    rating: 4.7,
    reviews: 341,
  ),
  Product(
    id: 'milo-loveseat',
    name: 'Milo Loveseat',
    category: ProductCategory.sofas,
    kind: FurnitureKind.loveseat,
    priceCents: 27900,
    colors: [_terracotta, _sage, _sand, _navy, _charcoal],
    description:
        'A compact two-seater with sloped arms and a supportive back. Sized '
        'for apartments without giving up comfort.',
    rating: 4.5,
    reviews: 188,
  ),
  Product(
    id: 'cloud-nine-sofa',
    name: 'Cloud Nine Sofa',
    category: ProductCategory.sofas,
    kind: FurnitureKind.sofa,
    priceCents: 45900,
    colors: [_cream, _sand, _stone, _blush, _forest],
    description:
        'Oversized cushions and a low, relaxed frame give this sofa its '
        'signature cloud-like feel. Soft to sit on, easy to style.',
    rating: 4.9,
    reviews: 402,
  ),
  Product(
    id: 'velvet-moon-loveseat',
    name: 'Velvet Moon Loveseat',
    category: ProductCategory.sofas,
    kind: FurnitureKind.loveseat,
    priceCents: 32900,
    colors: [_forest, _navy, _blush, _mustard, _charcoal],
    description:
        'Rich velvet upholstery over a sturdy hardwood frame. A bold, '
        'comfortable choice for lounges and entryways.',
    rating: 4.6,
    reviews: 119,
  ),

  // ---- Tables -------------------------------------------------------------
  Product(
    id: 'oakline-dining',
    name: 'Oakline Dining Table',
    category: ProductCategory.tables,
    kind: FurnitureKind.diningTable,
    priceCents: 24900,
    colors: [_oak, _walnut, _ash, _black, _white],
    description:
        'A solid wood dining table with a smooth, durable finish and slim '
        'legs. Comfortably seats six around a shared meal.',
    rating: 4.6,
    reviews: 167,
  ),
  Product(
    id: 'luna-coffee-table',
    name: 'Luna Coffee Table',
    category: ProductCategory.tables,
    kind: FurnitureKind.coffeeTable,
    priceCents: 11900,
    colors: [_oak, _walnut, _white, _black, _ash],
    description:
        'A round coffee table with a lower shelf for books and blankets. '
        'Soft edges keep movement around the sofa easy.',
    rating: 4.4,
    reviews: 82,
  ),
  Product(
    id: 'walnut-hub-dining',
    name: 'Walnut Hub Table',
    category: ProductCategory.tables,
    kind: FurnitureKind.diningTable,
    priceCents: 29900,
    colors: [_walnut, _oak, _black, _ash, _white],
    description:
        'A statement dining table with a deep tone and a thick top. '
        'Made to anchor open-plan kitchens and dining rooms.',
    rating: 4.8,
    reviews: 205,
  ),
  Product(
    id: 'pebble-side-table',
    name: 'Pebble Side Table',
    category: ProductCategory.tables,
    kind: FurnitureKind.coffeeTable,
    priceCents: 7900,
    colors: [_white, _oak, _black, _stone, _blush],
    description:
        'A small round table that fits beside a sofa or bed. Perfect for a '
        'lamp, a book and a cup of tea.',
    rating: 4.3,
    reviews: 64,
  ),

  // ---- Kitchen ------------------------------------------------------------
  Product(
    id: 'brio-bar-stool',
    name: 'Brio Bar Stool',
    category: ProductCategory.kitchen,
    kind: FurnitureKind.barStool,
    priceCents: 4900,
    colors: [_oak, _black, _white, _mustard, _sage],
    description:
        'A sturdy counter stool with a padded round seat and a brass-tone '
        'footrest. Stable, comfortable and easy to wipe clean.',
    rating: 4.5,
    reviews: 143,
  ),
  Product(
    id: 'chef-island',
    name: 'Chef Island',
    category: ProductCategory.kitchen,
    kind: FurnitureKind.kitchenIsland,
    priceCents: 42900,
    colors: [_white, _sage, _navy, _charcoal, _oak],
    description:
        'A freestanding kitchen island with a stone-look worktop and roomy '
        'cabinets underneath. Extra prep space where you need it.',
    rating: 4.7,
    reviews: 91,
  ),
  Product(
    id: 'aria-bar-stool',
    name: 'Aria Bar Stool',
    category: ProductCategory.kitchen,
    kind: FurnitureKind.barStool,
    priceCents: 5400,
    colors: [_blush, _sage, _charcoal, _oak, _cream],
    description:
        'A softly padded stool with splayed legs for extra stability. '
        'Pairs well with islands and breakfast bars.',
    rating: 4.4,
    reviews: 77,
  ),
  Product(
    id: 'studio-island',
    name: 'Studio Island',
    category: ProductCategory.kitchen,
    kind: FurnitureKind.kitchenIsland,
    priceCents: 36900,
    colors: [_charcoal, _oak, _white, _forest, _navy],
    description:
        'A compact island with three cabinet doors and a smooth worktop. '
        'Designed for studio kitchens and small family spaces.',
    rating: 4.5,
    reviews: 58,
  ),

  // ---- Beds ---------------------------------------------------------------
  Product(
    id: 'serene-queen-bed',
    name: 'Serene Queen Bed',
    category: ProductCategory.beds,
    kind: FurnitureKind.bed,
    priceCents: 49900,
    colors: [_stone, _cream, _sage, _navy, _blush],
    description:
        'An upholstered queen bed with a tall headboard and a quiet, '
        'neutral look. Solid slats support your mattress evenly.',
    rating: 4.8,
    reviews: 276,
  ),
  Product(
    id: 'dune-bed',
    name: 'Dune Bed',
    category: ProductCategory.beds,
    kind: FurnitureKind.bed,
    priceCents: 45900,
    colors: [_sand, _terracotta, _charcoal, _forest, _cream],
    description:
        'A low-profile bed with a warm, textured headboard. Easy to '
        'assemble and easy to style with layered bedding.',
    rating: 4.6,
    reviews: 134,
  ),
  Product(
    id: 'haven-platform-bed',
    name: 'Haven Platform Bed',
    category: ProductCategory.beds,
    kind: FurnitureKind.bed,
    priceCents: 52900,
    colors: [_charcoal, _oak, _white, _navy, _sage],
    description:
        'A platform bed with a wide headboard and sturdy legs. Minimal '
        'design that works in modern and classic bedrooms.',
    rating: 4.7,
    reviews: 189,
  ),

  // ---- Decor --------------------------------------------------------------
  Product(
    id: 'halo-floor-lamp',
    name: 'Halo Floor Lamp',
    category: ProductCategory.decor,
    kind: FurnitureKind.floorLamp,
    priceCents: 8900,
    colors: [_cream, _mustard, _white, _blush, _sage],
    description:
        'A slim floor lamp with a fabric shade that spreads a soft, warm '
        'glow. Great beside sofas and reading chairs.',
    rating: 4.5,
    reviews: 101,
  ),
  Product(
    id: 'arc-reading-lamp',
    name: 'Arc Reading Lamp',
    category: ProductCategory.decor,
    kind: FurnitureKind.floorLamp,
    priceCents: 9900,
    colors: [_white, _black, _terracotta, _navy, _cream],
    description:
        'A tall lamp with a wide shade and a weighted base. Gives focused '
        'light for reading and a gentle glow for evenings.',
    rating: 4.4,
    reviews: 69,
  ),
  Product(
    id: 'library-stack',
    name: 'Library Stack',
    category: ProductCategory.decor,
    kind: FurnitureKind.bookshelf,
    priceCents: 15900,
    colors: [_oak, _walnut, _white, _black, _sage],
    description:
        'A three-shelf bookcase with a sturdy frame and a deep back panel. '
        'Plenty of room for books, plants and keepsakes.',
    rating: 4.6,
    reviews: 158,
  ),
  Product(
    id: 'slim-shelf',
    name: 'Slim Shelf',
    category: ProductCategory.decor,
    kind: FurnitureKind.bookshelf,
    priceCents: 12900,
    colors: [_walnut, _oak, _white, _charcoal, _ash],
    description:
        'A narrow bookshelf that fits hallways and tight corners without '
        'losing storage space.',
    rating: 4.3,
    reviews: 47,
  ),
];
