class Item {
  int? id;
  String name;
  String photo;
  String category;
  int price;
  int stock;

  Item({
    this.id,
    required this.name,
    required this.photo,
    required this.category,
    required this.price,
    required this.stock,
  });

  // Convert an Item to a Map for database interactions
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'category': category,
      'price': price,
      'stock': stock,
    };
  }

  // Create an Item from a Map (database query result)
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      photo: map['photo'],
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
    );
  }
}
