import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:orderer_app/components/address_card.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:http/http.dart' as http;
import '../components/layout.dart';

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

class _MainManagerPage extends State<MainManagerPage> {
  bool _loading = false;
  List<Order> _orders = [];
  String? _error;

  Future<void> _getOrders() async {
    setState(() {
      _loading = true;
      _orders = [];
    });

    final serverAddress = widget.serverAddress;
    final serverPort = widget.serverPort;

    try {
      final response = await http
          .get(
            Uri.http('$serverAddress:$serverPort', '/order'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final List<dynamic> ordersJson = jsonDecode(response.body);
      final orders = ordersJson.map((json) => Order.fromJson(json)).toList();
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore in GET $serverAddress:$serverPort/order'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _startManager() async {
    _getOrders();
  }

  @override
  void initState() {
    super.initState();
    _startManager();
  }

  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: const Text('Gestione ordini'),
      // print card with '$serverAddress:$serverPort'
      body: Column(
        children: [
          ServerAddressCard(
            serverAddress: widget.serverAddress,
            serverPort: widget.serverPort,
            type: 'server API',
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
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Column(
              children: [
                const Text(
                  'Errore',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_error!),
                TextButton(
                  onPressed: _startManager,
                  child: const Text('Riprova'),
                ),
              ],
            )
          else if (_orders.isEmpty)
            const Center(child: Text('Nessun ordine'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final amount = order.dishes
                      .map((e) => e.quantity * e.dish.price)
                      .reduce((a, b) => a + b);
                  final amountStr = (amount / 100).toStringAsFixed(2);
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: Text(
                              'Tavolo ${order.table.number.toString()} - €$amountStr'),
                          subtitle: Text(order.dishes
                              .map((e) =>
                                  '${e.quantity}x${e.dish.name} (€${(e.dish.price / 100).toStringAsFixed(2)})')
                              .join(', ')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null, // TODO navigate to new order
        tooltip: 'Nuovo ordine',
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
