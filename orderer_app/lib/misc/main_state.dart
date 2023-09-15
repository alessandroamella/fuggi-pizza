import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orderer_app/misc/api_service.dart';
import 'package:orderer_app/misc/connection_info.dart';
import 'package:orderer_app/misc/order.dart';

class MainState extends ChangeNotifier {
  ConnectionInfo? _connectionInfo;
  List<Order>? _orders;
  List<Dish>? _dishes;
  List<TableInfo>? _tables;
  List<Category>? _categories;

  ConnectionInfo? get connectionInfo => _connectionInfo;
  set connectionInfo(ConnectionInfo? connectionInfo) {
    _connectionInfo = connectionInfo;
    notifyListeners();
  }

  ApiService get api => ApiService(info: _connectionInfo!);

  Future<void> _fetchAll() async {
    final routes = [
      APIRoute.dish,
      APIRoute.order,
      APIRoute.table,
      APIRoute.category
    ];

    await Future.wait(
      (routes).map(
        (r) =>
            api.client.get(api.uri(r)).timeout(const Duration(seconds: 5)).then(
          (response) {
            if (response.statusCode != 200) {
              throw Exception(response.body);
            }

            final List<dynamic> ordersJson = jsonDecode(response.body);

            switch (r) {
              case APIRoute.dish:
                _dishes =
                    ordersJson.map((json) => Dish.fromJson(json)).toList();
                break;
              case APIRoute.order:
                _orders =
                    ordersJson.map((json) => Order.fromJson(json)).toList();
                break;
              case APIRoute.table:
                _tables =
                    ordersJson.map((json) => TableInfo.fromJson(json)).toList();
                break;
              case APIRoute.category:
                _categories =
                    ordersJson.map((json) => Category.fromJson(json)).toList();
                break;
            }
          },
        ),
      ),
    );

    if ((_orders ?? _dishes ?? _tables ?? _categories) == null) {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _ensureLoaded() async {
    if ((_orders ?? _dishes ?? _tables ?? _categories) == null) {
      await _fetchAll();
    }
  }

  Future<List<TableInfo>> getTables() async {
    await _ensureLoaded();
    return _tables!;
  }

  Future<List<Dish>> getDishes() async {
    await _ensureLoaded();
    return _dishes!;
  }

  Future<List<Order>> getOrders() async {
    await _ensureLoaded();
    return _orders!;
  }

  Future<List<Category>> getCategories() async {
    await _ensureLoaded();
    return _categories!;
  }

  Future<Order> getOrder(int id) async {
    await _ensureLoaded();
    return _orders!.firstWhere((o) => o.id == id);
  }

  Future<void> addOrder(Order order) async {
    await _ensureLoaded();
    final response = await api.client
        .post(
          api.uri('/order'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(order.toServerJson()),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final orderJson = jsonDecode(response.body);
    // final newOrder = Order.fromJson(orderJson);

    // l'unico campo nuovo è l'id
    final newOrder = Order(
        orderJson['id'], order.date, order.dishes, order.table,
        paymentDate: order.paymentDate, notes: order.notes);

    _orders!.add(newOrder);
    notifyListeners();
  }

  Future<void> updateOrder(Order order) async {
    await _ensureLoaded();
    final response = await api.client
        .put(
          api.uri('/order/${order.id}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(order.toJson()),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final orderJson = jsonDecode(response.body);
    final updatedOrder = Order(
        orderJson['id'], order.date, order.dishes, order.table,
        paymentDate: order.paymentDate, notes: order.notes);

    _orders![_orders!.indexWhere((o) => o.id == updatedOrder.id)] =
        updatedOrder;
    notifyListeners();
  }

  Future<void> removeOrder(Order order) async {
    await _ensureLoaded();
    final response = await api.client
        .delete(api.uri('/order/${order.id}'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    _orders!.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }
}
