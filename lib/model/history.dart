class History {
  final int? id;
  final int itemId;
  final String itemName;
  final String type;
  final int quantity;
  final String date;

  History({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      itemId: map['itemId'],
      itemName: map['itemName'],
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'],
    );
  }
}