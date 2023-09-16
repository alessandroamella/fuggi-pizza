import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:orderer_app/misc/api_service.dart';
import '../misc/connection_info.dart';

class InsertAddressDialog extends StatefulWidget {
  final Function(String) onSuccess;
  final Function(ApiService) pingServer;
  final int apiServerPort;
  final String? defaultAddress;

  const InsertAddressDialog({
    super.key,
    required this.onSuccess,
    required this.pingServer,
    required this.apiServerPort,
    this.defaultAddress,
  });

  @override
  State<StatefulWidget> createState() => _InsertAddressDialog();
}

enum PingStatus {
  pinging,
  success,
  invalid,
  error,
}

String getPingStatusStr(PingStatus? status) {
  switch (status) {
    case PingStatus.pinging:
      return 'Ping in corso...';
    case PingStatus.success:
      return 'Server raggiungibile';
    case PingStatus.invalid:
      return 'Indirizzo non valido';
    case PingStatus.error:
      return 'Server non raggiungibile';
    default:
      return 'Errore';
  }
}

class _InsertAddressDialog extends State<InsertAddressDialog> {
  String serverAddress = "";
  final _controller = TextEditingController();
  PingStatus? _pingStatus;

  @override
  void initState() {
    super.initState();

    if (widget.defaultAddress != null) {
      serverAddress = widget.defaultAddress!;
      _controller.text = widget.defaultAddress!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasicDialogAlert(
      title: const Text('Inserisci indirizzo server'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Inserisci manualmente l\'indirizzo del server'),
            const SizedBox(height: 10),
            if (_pingStatus != null)
              Text(
                getPingStatusStr(_pingStatus),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            if (_pingStatus == PingStatus.pinging)
              const Center(child: CircularProgressIndicator())
            else
              TextField(
                enabled: _pingStatus != PingStatus.pinging,
                controller: _controller,
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
                  if (serverAddress.isNotEmpty) {
                    setState(() {
                      _pingStatus = PingStatus.pinging;
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
                          _pingStatus = PingStatus.success;
                        });

                        Navigator.pop(context);
                        widget.onSuccess(serverAddress);
                      } else {
                        setState(() {
                          _pingStatus = PingStatus.error;
                        });
                      }
                    });
                  } else {
                    setState(() {
                      _pingStatus = PingStatus.invalid;
                    });
                  }
                },
        ),
      ],
    );
  }
}
