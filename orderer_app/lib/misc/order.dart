class Order {
  final int id;
  final DateTime date;
  final List<OrderedDish> dishes;
  final TableInfo table;
  final DateTime? paymentDate;
  final String? notes;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      json['id'],
      DateTime.parse(json['date']),
      json['dishes']
          .map<OrderedDish>((dish) => OrderedDish.fromJson(dish))
          .toList(),
      TableInfo.fromJson(json['table']),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
      'table': table.toJson(),
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Order.empty() {
    return Order(
      0,
      DateTime.now(),
      [],
      TableInfo(0),
    );
  }

  Order(this.id, this.date, this.dishes, this.table,
      {this.paymentDate, this.notes});
}

class OrderedDish {
  final Dish dish;
  final int quantity;
  final String? notes;

  factory OrderedDish.fromJson(Map<String, dynamic> json) {
    return OrderedDish(
      Dish.fromJson(json['dish']),
      json['quantity'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish': dish.toJson(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  OrderedDish(this.dish, this.quantity, {this.notes});
}

class Dish {
  final int id;
  final String name;
  final String? description;
  final int price;
  final Category? category;

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      json['id'],
      json['name'],
      json['price'],
      category:
          json['category'] == null ? null : Category.fromJson(json['category']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category?.toJson(),
      'description': description,
    };
  }

  Dish(this.id, this.name, this.price, {this.category, this.description});
}

class TableInfo {
  final int number;
  final int? seats;
  final String? notes;

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      json['number'],
      seats: json['seats'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'seats': seats,
      'notes': notes,
    };
  }

  TableInfo(this.number, {this.seats, this.notes});
}

class Category {
  final int id;
  final String name;

  Category(this.id, this.name);

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(json['id'], json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
