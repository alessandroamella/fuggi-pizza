import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:orderer_app/misc/api_service.dart';
import '../misc/connection_info.dart';

class InsertAddressDialog extends StatefulWidget {
  final Function(String) onSuccess;
  final Function(ApiService) pingServer;
  final int apiServerPort;

  const InsertAddressDialog({
    super.key,
    required this.onSuccess,
    required this.pingServer,
    required this.apiServerPort,
  });

  @override
  State<StatefulWidget> createState() => _InsertAddressDialog();
}

enum PingStatus {
  init,
  pinging,
  success,
  error,
}

String getPingStatusStr(PingStatus? status) {
  switch (status) {
    case PingStatus.init:
      return 'Inizializzazione';
    case PingStatus.pinging:
      return 'Ping in corso...';
    case PingStatus.success:
      return 'Server raggiungibile';
    case PingStatus.error:
      return 'Server non raggiungibile';
    default:
      return 'Errore';
  }
}

class _InsertAddressDialog extends State<InsertAddressDialog> {
  String serverAddress = "";
  String? _manualPingStatus;
  PingStatus? _pingStatus = PingStatus.init;

  @override
  Widget build(BuildContext context) {
    return BasicDialogAlert(
      title: const Text('Inserisci indirizzo server API'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Inserisci manualmente l\'indirizzo del server'),
            const SizedBox(height: 10),
            if (_manualPingStatus != null)
              Text(
                _manualPingStatus!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            if (_pingStatus == PingStatus.pinging)
              const Center(child: CircularProgressIndicator())
            else
              TextField(
                enabled: _pingStatus != PingStatus.pinging,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Indirizzo',
                ),
                onChanged: (value) {
                  setState(() {
                    serverAddress = value;
                  });
                },
              ),
          ],
        ),
      ),
      actions: [
        BasicDialogAction(
          title: const Text('Conferma'),
          onPressed: _pingStatus == PingStatus.pinging
              ? null
              : () {
                  if (serverAddress != null) {
                    setState(() {
                      _manualPingStatus = 'Ping in corso...';
                    });

                    widget
                        .pingServer(ApiService(
                      info: ConnectionInfo(
                        serverAddress: serverAddress,
                        serverPort: widget.apiServerPort,
                      ),
                    ))
                        .then((canPing) {
                      if (canPing) {
                        setState(() {
                          _manualPingStatus = null;
                        });

                        Navigator.pop(context);
                        widget.onSuccess(serverAddress);
                      } else {
                        setState(() {
                          _manualPingStatus = 'Server non raggiungibile';
                        });
                      }
                    });
                  } else {
                    setState(() {
                      _manualPingStatus = 'Inserisci un indirizzo valido';
                    });
                  }
                },
        ),
      ],
    );
  }
}
