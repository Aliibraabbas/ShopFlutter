class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> images;
  final String description;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.images,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'images': images,
      'description': description,
      'category': category,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['image'] as String? ?? '';

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      thumbnail: imageUrl,
      images: [imageUrl], // l'API Fake Store ne donne qu'une image
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

}
