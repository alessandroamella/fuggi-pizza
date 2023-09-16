import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:provider/provider.dart';

// used for both creating and editing an order
class ViewOrderedDishesPage extends StatefulWidget {
  final Function(List<OrderedDish>)? onDishesSelect;
  final List<OrderedDish> orderedDishes;
  final Function(bool)? onLoading;
  final TableInfo? selectedTable;
  final CrudAction action;
  final Order? order;

  const ViewOrderedDishesPage({
    super.key,
    required this.onDishesSelect,
    required this.orderedDishes,
    required this.onLoading,
    required this.selectedTable,
    required this.action,
    this.order,
  });

  @override
  State<ViewOrderedDishesPage> createState() => _ViewOrderedDishesPage();
}

class _ViewOrderedDishesPage extends State<ViewOrderedDishesPage> {
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.order != null
                ? 'Ordine #${widget.order!.id}'
                : 'Riepilogo ordine',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  (_error != null ? 0.4 : 0.58),
              minHeight: MediaQuery.of(context).size.height *
                  (_error != null ? 0.4 : 0.58),
            ),
            child: widget.orderedDishes.isEmpty
                ? const Center(child: Text('Nessun piatto selezionato'))
                : SingleChildScrollView(
                    child: ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.orderedDishes.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        List<OrderedDish> orderedDishes =
                            List.from(widget.orderedDishes);

                        final dish = orderedDishes[index].dish;
                        return ListTile(
                          title: Text(dish.name),
                          subtitle: Text(
                              'Prezzo: €${(dish.price / 100).toStringAsFixed(2)}${orderedDishes[index].notes != null ? '\nNote: ${orderedDishes[index].notes}' : ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.onDishesSelect != null)
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          if (orderedDishes[index].quantity >
                                              1) {
                                            orderedDishes[index].quantity--;
                                          } else {
                                            orderedDishes.removeAt(index);
                                          }
                                          widget.onDishesSelect!(orderedDishes);
                                        },
                                ),
                              Text(orderedDishes[index].quantity.toString()),
                              if (widget.onDishesSelect != null)
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          orderedDishes[index].quantity++;
                                          widget.onDishesSelect!(orderedDishes);
                                        },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const Divider(height: 1, thickness: 2),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.action != CrudAction.view)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tavolo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.selectedTable?.number.toString() ??
                              'DA INSERIRE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: widget.selectedTable == null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  if (widget.order != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm', 'it_IT')
                              .format(widget.order!.date),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Totale',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '€${(widget.orderedDishes.fold<int>(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  element.dish.price * element.quantity,
                            ) / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Column(
                      children: [
                        const Text(
                          'Errore',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Center(child: Text(_error!)),
                        const SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (widget.action != CrudAction.view)
            Center(
              child: ElevatedButton(
                onPressed: widget.orderedDishes.isEmpty ||
                        widget.action != CrudAction.create ||
                        widget.selectedTable == null
                    ? null
                    : () {
                        setState(() {
                          _loading = true;
                        });
                        if (widget.onLoading != null) {
                          widget.onLoading!(true);
                        }

                        // Order(this.id, this.date, this.dishes, this.table,
                        // {this.paymentDate, this.notes});
                        Order order = Order(
                          -1,
                          DateTime.now(),
                          widget.orderedDishes,
                          widget.selectedTable!,
                        );
                        Provider.of<MainState>(context, listen: false)
                            .addOrder(order)
                            .then(Navigator.of(context).pop)
                            .catchError((e) {
                          setState(() {
                            _error = e.toString();
                            _loading = false;
                          });
                          if (widget.onLoading != null) {
                            widget.onLoading!(false);
                          }
                        });
                      },
                child: _loading
                    ? const CircularProgressIndicator()
                    : widget.action == CrudAction.create
                        ? const Text('Crea ordine')
                        : const Text('Modifica ordine'),
              ),
            ),
        ],
      ),
    );
  }
}
