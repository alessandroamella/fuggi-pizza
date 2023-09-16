import 'package:flutter/material.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:orderer_app/pages/manage_order/view_ordered_dishes.dart';
import '../components/layout.dart';

class ViewOrderPage extends StatelessWidget {
  final Order order;

  const ViewOrderPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: const Text('Visualizza ordine'),
      body: ViewOrderedDishesPage(
        onDishesSelect: null,
        onLoading: null,
        selectedTable: null,
        orderedDishes: order.dishes,
        action: CrudAction.view,
        order: order,
      ),
    );
  }
}
