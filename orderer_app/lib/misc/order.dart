class Order {
  final int id;
  final DateTime date;
  final List<OrderedDish> dishes;
  final Table table;
  final DateTime? paymentDate;
  final String? notes;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      json['id'],
      DateTime.parse(json['date']),
      json['dishes']
          .map<OrderedDish>((dish) => OrderedDish.fromJson(dish))
          .toList(),
      Table.fromJson(json['table']),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      notes: json['notes'],
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

  Dish(this.id, this.name, this.price, {this.category, this.description});
}

class Table {
  final int number;
  final int? seats;
  final String? notes;

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      json['number'],
      seats: json['seats'],
      notes: json['notes'],
    );
  }

  Table(this.number, {this.seats, this.notes});
}

class Category {
  final int id;
  final String name;

  Category(this.id, this.name);

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(json['id'], json['name']);
  }
}
