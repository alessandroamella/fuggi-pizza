import 'package:flutter/material.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:orderer_app/pages/manage_order/select_dishes.dart';
import 'package:orderer_app/pages/manage_order/select_table.dart';
import 'package:orderer_app/pages/manage_order/view_ordered_dishes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../components/layout.dart';

class NewOrderPage extends StatefulWidget {
  final Order? startingOrder;

  const NewOrderPage({
    super.key,
    this.startingOrder,
  });

  @override
  State<NewOrderPage> createState() => _NewOrderPage();
}

class _NewOrderPage extends State<NewOrderPage> {
  final PageController _controller = PageController();

  TableInfo? selectedTable;
  List<OrderedDish> orderedDishes = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    selectedTable = widget.startingOrder?.table;
    orderedDishes = widget.startingOrder?.dishes ?? [];
  }

  // TODO ask for confirmation before exiting the page

  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: const Text('Nuovo ordine'),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                children: [
                  SelectTablePage(
                    selectedTable: selectedTable,
                    onTableSelected: (TableInfo? table) {
                      setState(() {
                        selectedTable = table;
                      });
                    },
                    isLoading: _loading,
                    nextPage: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  SelectDishesPage(
                    selectedDishes: orderedDishes,
                    onDishesSelect: (List<OrderedDish> dishes) {
                      setState(() {
                        orderedDishes = dishes;
                      });
                    },
                    isLoading: _loading,
                  ),
                  ViewOrderedDishesPage(
                    onDishesSelect: (List<OrderedDish> dishes) {
                      setState(() {
                        orderedDishes = dishes;
                      });
                    },
                    onLoading: (bool loading) {
                      setState(() {
                        _loading = loading;
                      });
                    },
                    selectedTable: selectedTable,
                    orderedDishes: orderedDishes,
                    action: CrudAction.create,
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
