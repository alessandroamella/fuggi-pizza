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
      'tableId': table.toJson(),
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      'dishes': dishes.map((dish) => dish.toServerJson()).toList(),
      'tableId': table.number,
      if (paymentDate != null) 'paymentDate': paymentDate?.toIso8601String(),
      if (notes != null) 'notes': notes,
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
  final DishWithoutCategory dish;
  int quantity;
  String? notes;

  factory OrderedDish.fromJson(Map<String, dynamic> json) {
    return OrderedDish(
      DishWithoutCategory.fromJson(json['dish']),
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

  Map<String, dynamic> toServerJson() {
    return {
      'dishId': dish.id,
      'quantity': quantity,
      if (notes != null) 'notes': notes,
    };
  }

  OrderedDish(this.dish, this.quantity, {this.notes});
}

class DishWithoutCategory {
  final int id;
  final String name;
  final int price;

  factory DishWithoutCategory.fromJson(Map<String, dynamic> json) {
    return DishWithoutCategory(
      json['id'],
      json['name'],
      json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  DishWithoutCategory(
    this.id,
    this.name,
    this.price,
    /* this.category, {this.description}*/
  );
}

class Dish extends DishWithoutCategory {
  final String? description;
  final Category category;

  @override
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      json['id'],
      json['name'],
      json['price'],
      Category.fromJson(json['category']),
      description: json['description'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category.toJson(),
      'description': description,
    };
  }

  Dish(int id, String name, int price, this.category, {this.description})
      : super(id, name, price);
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
