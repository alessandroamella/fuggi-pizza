import 'package:flutter/material.dart';
import 'package:orderer_app/components/searchable_menu.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:provider/provider.dart';
import '../components/layout.dart';

// used for both creating and editing an order
class ManageOrderPage extends StatefulWidget {
  final Order? startingOrder;
  final Future<void> Function(Order)? onCrudDone;
  final CrudAction action;

  const ManageOrderPage({
    super.key,
    this.startingOrder,
    this.onCrudDone,
    required this.action,
  });

  @override
  State<ManageOrderPage> createState() => _ManageOrderPage();
}

class _ManageOrderPage extends State<ManageOrderPage> {
  late Future<List<TableInfo>> _tables;
  late Future<List<Dish>> _dishes;
  // late Future<List<Category>> _categories;

  bool _loading = false;
  String? _error;

  TableInfo? selectedTable;
  List<OrderedDish> orderedDishes = [];

  @override
  void initState() {
    super.initState();

    _tables = Provider.of<MainState>(context, listen: false).getTables();
    _dishes = Provider.of<MainState>(context, listen: false).getDishes();
    // _categories =
    //     Provider.of<MainState>(context, listen: false).getCategories();

    selectedTable = widget.startingOrder?.table;
    orderedDishes = widget.startingOrder?.dishes ?? [];
  }

  // TODO ask for confirmation before exiting the page

  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: widget.action == CrudAction.create
          ? const Text('Nuovo ordine')
          : const Text('Modifica ordine'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: _tables,
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Errore: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.hasData) {
                      final tables = snapshot.data as List<TableInfo>;
                      selectedTable = tables.first;

                      return selectedTable == null
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<TableInfo>(
                              value: selectedTable,
                              onChanged: (TableInfo? newValue) {
                                setState(() {
                                  selectedTable = newValue!;
                                });
                              },
                              items: tables.map((TableInfo table) {
                                return DropdownMenuItem<TableInfo>(
                                  value: table,
                                  child: Text('Tavolo ${table.number}'),
                                );
                              }).toList(),
                              decoration:
                                  const InputDecoration(labelText: 'Tavolo'),
                            );
                    } else {
                      return const Center(
                        child: Text('Nessun tavolo disponibile'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
              const SizedBox(height: 20),
              // TextField(
              //   controller: searchController,
              //   onChanged: (String value) {
              //     // Implementa la logica di ricerca dei piatti
              //     // e aggiorna la lista dei piatti disponibili.
              //   },
              //   decoration: const InputDecoration(labelText: 'Cerca Piatto'),
              // ),
              FutureBuilder(
                future: _dishes,
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Errore: ${snapshot.error}'),
                      );
                    }
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      return SizedBox(
                        height: 500,
                        child: SearchableMenu(
                          dishes: snapshot.data as List<Dish>,
                          onSelect: (Dish dish) {
                            if (_loading) return;
                            setState(() {
                              final index = orderedDishes.indexWhere(
                                  (element) => element.dish == dish);
                              if (index != -1) {
                                orderedDishes[index].quantity++;
                              } else {
                                orderedDishes.add(OrderedDish(dish, 1));
                              }
                            });
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('Nessun piatto disponibile'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ordine attuale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              if (orderedDishes.isEmpty)
                const Center(child: Text('Nessun piatto selezionato'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: orderedDishes.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    final dish = orderedDishes[index].dish;
                    return ListTile(
                      title: Text(dish.name),
                      subtitle: Text(
                          'Prezzo: €${(dish.price / 100).toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (orderedDishes[index].quantity > 1) {
                                  orderedDishes[index].quantity--;
                                } else if (orderedDishes[index].quantity == 1) {
                                  orderedDishes.removeAt(index);
                                }
                              });
                            },
                          ),
                          Text(orderedDishes[index].quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _loading
                                ? null
                                : () {
                                    setState(() {
                                      orderedDishes[index].quantity++;
                                    });
                                  },
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),
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
                    '€${(orderedDishes.fold<int>(
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
                    Center(
                      child: Text(
                        _error!,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              Center(
                child: ElevatedButton(
                  onPressed: orderedDishes.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _loading = true;
                          });

                          // Order(this.id, this.date, this.dishes, this.table,
                          // {this.paymentDate, this.notes});
                          Order order = Order(
                            -1,
                            DateTime.now(),
                            orderedDishes,
                            selectedTable!,
                          );
                          Provider.of<MainState>(context, listen: false)
                              .addOrder(order)
                              .then(Navigator.of(context).pop)
                              .catchError((e) {
                            setState(() {
                              _error = e.toString();
                              _loading = false;
                            });
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
        ),
      ),
    );
  }
}
