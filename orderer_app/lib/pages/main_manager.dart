import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orderer_app/components/address_card.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:orderer_app/pages/new_order.dart';
import 'package:orderer_app/pages/view_order.dart';
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

enum CrudAction { view, create, edit }

class _MainManagerPage extends State<MainManagerPage> {
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it_IT', null);
  }

  Future<void> _deleteOrder(MainState state, Order order) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Elimina ordine'),
          content:
              Text('Sei sicuro di voler eliminare l\'ordine #${order.id}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: _isDeleting
                  ? null
                  : () {
                      setState(() {
                        _isDeleting = true;
                      });

                      state.deleteOrder(order).then((value) {
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Errore: $error'),
                          ),
                        );
                        Navigator.of(context).pop();
                      });
                    },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    ).then((value) => {
          setState(() {
            _isDeleting = false;
          })
        });
  }

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
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                        return ViewOrderPage(
                                          order: order,
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
                                            '#${order.id} - Tav. ${order.table.number} - €$amountStr'),
                                        subtitle: Text(order.dishes
                                            .map((e) =>
                                                '${e.quantity}x${e.dish.name}')
                                            .join(', ')),
                                        trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: _isDeleting
                                                ? null
                                                : () {
                                                    _deleteOrder(state, order);
                                                  }),
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
              builder: (context) => const NewOrderPage(),
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
