import 'package:flutter/material.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:provider/provider.dart';
import '../components/layout.dart';

// used for both creating and editing an order
class ManageOrderPage extends StatefulWidget {
  final Order? order;
  final Future<void> Function(Order)? onCrudDone;
  final CrudAction action;

  const ManageOrderPage({
    super.key,
    this.order,
    this.onCrudDone,
    required this.action,
  });

  @override
  State<ManageOrderPage> createState() => _ManageOrderPage();
}

class _ManageOrderPage extends State<ManageOrderPage> {
  // final TextEditingController quantityController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  late Future<List<TableInfo>> _tables;
  late Future<List<Dish>> _dishes;

  TableInfo? selectedTable;
  List<OrderedDish>? orderedDishes = [];

  @override
  void initState() {
    super.initState();
    _tables = Provider.of<MainState>(context, listen: false).getTables();
    _dishes = Provider.of<MainState>(context, listen: false).getDishes();
  }

  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: const Text('Nuovo ordine'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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

                    return DropdownButtonFormField<TableInfo>(
                      value: selectedTable,
                      onChanged: (TableInfo? newValue) {
                        setState(() {
                          selectedTable = newValue!;
                        });
                      },
                      items: tables
                          .map<DropdownMenuItem<TableInfo>>((TableInfo table) {
                        return DropdownMenuItem<TableInfo>(
                          value: table,
                          child: Text('Tavolo ${table.number}'),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: 'Tavolo'),
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
            TextField(
              controller: searchController,
              onChanged: (String value) {
                // Implementa la logica di ricerca dei piatti
                // e aggiorna la lista dei piatti disponibili.
              },
              decoration: const InputDecoration(labelText: 'Cerca Piatto'),
            ),
            FutureBuilder(
              future: _dishes,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Errore: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.hasData) {
                    final dishes = snapshot.data as List<Dish>;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: dishes.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dish = dishes[index];
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
                                  // Implementa la logica per rimuovere il piatto dall'ordine.
                                },
                              ),
                              const Text('0'), // Mostra la quantità selezionata
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  // Implementa la logica per aggiungere il piatto all'ordine.
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
            ElevatedButton(
              onPressed: () {
                // Implementa la logica per salvare l'ordine.
              },
              child: const Text('Salva Ordine'),
            ),
          ],
        ),
      ),
    );
  }
}
