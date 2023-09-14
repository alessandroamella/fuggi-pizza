import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orderer_app/misc/connection_info.dart';

enum ServerType { mDNS, api }

String getServerTypeStr(ServerType type) {
  switch (type) {
    case ServerType.mDNS:
      return 'mDNS';
    case ServerType.api:
      return 'API';
  }
}

class ServerAddressCard extends StatelessWidget {
  final ConnectionInfo? connectionInfo;
  final ServerType type;

  const ServerAddressCard({
    super.key,
    this.connectionInfo,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final serverName = connectionInfo?.serverName;
    final serverAddress = connectionInfo?.serverAddress;
    final serverPort = connectionInfo?.serverPort;

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.network_wifi),
            title: Text(serverName ?? '$serverAddress:$serverPort'),
            subtitle: Text(serverName == null
                ? getServerTypeStr(type)
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
