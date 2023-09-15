import 'package:flutter/material.dart';
import 'package:orderer_app/components/address_card.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/manage_order.dart';
import 'package:provider/provider.dart';
import '../components/layout.dart';
import '../misc/connection_info.dart';

class MainManagerPage extends StatefulWidget {
  final String serverAddress;
  final int serverPort;

  const MainManagerPage({
    super.key,
    required this.serverAddress,
    required this.serverPort,
  });

  @override
  State<MainManagerPage> createState() => _MainManagerPage();
}

enum CrudAction { create, edit }

class _MainManagerPage extends State<MainManagerPage> {
  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: const Text('Gestione ordini'),
      // print card with '$serverAddress:$serverPort'
      body: Column(
        children: [
          ServerAddressCard(
            connectionInfo: ConnectionInfo(
              serverAddress: widget.serverAddress,
              serverPort: widget.serverPort,
            ),
            type: ServerType.api,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ordini',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // futurebuilder of _orders
          Consumer<MainState>(
            builder: (context, state, child) {
              return FutureBuilder(
                future: state.getOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          const Text(
                            'Errore',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(snapshot.error.toString()),
                        ],
                      );
                    } else {
                      final orders = snapshot.data as List<Order>;

                      if (orders.isEmpty) {
                        return const Center(child: Text('Nessun ordine'));
                      } else {
                        return Expanded(
                          // child: RefreshIndicator(
                          //   onRefresh: _reloadOrders,
                          child: ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final amount = order.dishes
                                  .map((e) => e.quantity * e.dish.price)
                                  .reduce((a, b) => a + b);
                              final amountStr =
                                  (amount / 100).toStringAsFixed(2);

                              return InkWell(
                                onTap: () {
                                  // Naviga a una nuova pagina quando la Card viene toccata.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        // Qui puoi creare la tua nuova pagina e passare i dati necessari.
                                        return ManageOrderPage(
                                          action: CrudAction.edit,
                                          startingOrder: order,
                                          // TODO onCrudDone: _reloadOrders,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading:
                                            const Icon(Icons.shopping_cart),
                                        title: Text(
                                            'Tavolo ${order.table.number.toString()} - €$amountStr'),
                                        subtitle: Text(order.dishes
                                            .map((e) =>
                                                '${e.quantity}x${e.dish.name}')
                                            .join(', ')),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // ),
                        );
                      }
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageOrderPage(
                action: CrudAction.create,
                onCrudDone: null,
              ),
            ),
          );
        },
        tooltip: 'Nuovo ordine',
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
