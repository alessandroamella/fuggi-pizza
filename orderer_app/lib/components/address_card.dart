import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServerAddressCard extends StatelessWidget {
  final String? serverName;
  final String serverAddress;
  final int serverPort;
  final String type;

  const ServerAddressCard({
    super.key,
    this.serverName,
    required this.serverAddress,
    required this.serverPort,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.network_wifi),
            title: Text(serverName ?? '$serverAddress:$serverPort'),
            subtitle: Text(serverName == null
                ? "Indirizzo $type"
                : '$serverAddress:$serverPort'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Copia'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: serverAddress));
                  // show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Indirizzo copiato'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
