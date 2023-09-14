import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:orderer_app/components/address_card.dart';
import 'package:orderer_app/components/insert_addr_dialog.dart';
import 'package:orderer_app/components/layout.dart';
import 'package:orderer_app/misc/api_service.dart';
import 'package:orderer_app/misc/connection_info.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:provider/provider.dart';
import '../misc/local_db.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    required this.mdnsServiceName,
    required this.apiServerPort,
  });

  final String mdnsServiceName;
  final int apiServerPort;

  @override
  State<StartPage> createState() => _StartPageState();
}

enum MDNSStatus {
  init,
  dbFetch,
  dbSave,
  mdnsDiscovery,
  manualPing,
  serverPing,
  ready,
}

String getMDNSString(MDNSStatus? status) {
  switch (status) {
    case MDNSStatus.init:
      return 'Inizializzazione';
    case MDNSStatus.dbFetch:
      return 'Recupero impostazioni';
    case MDNSStatus.dbSave:
      return 'Salvataggio impostazioni';
    case MDNSStatus.mdnsDiscovery:
      return 'Ricerca server mDNS';
    case MDNSStatus.serverPing:
      return 'Verifica server (ping)';
    case MDNSStatus.ready:
      return 'Pronto';
    default:
      return 'Errore';
  }
}

class _StartPageState extends State<StartPage> {
  bool _loading = false;
  BonsoirDiscovery? _mdnsDiscovery;
  MDNSStatus? _mdnsStatus = MDNSStatus.init;
  String? _error;
  Timer? _mdnsTimer;

  final localSettingsDB = LocalSettingsDatabase();

  String? serverName;
  String? serverAddress;
  int? serverPort;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    setState(() {
      _loading = true;
      _mdnsStatus = MDNSStatus.dbFetch;
    });

    final retrievedSettings = await localSettingsDB.getLocalSettings();

    if (retrievedSettings != null) {
      // try to ping server
      final canPing = await _pingServer(
        ApiService(
          info: ConnectionInfo(
            serverName: 'Server salvato',
            serverAddress: retrievedSettings.serverAddress,
            serverPort: retrievedSettings.serverPort,
          ),
        ),
      );
      if (canPing) {
        // ok
        setState(() {
          serverName = 'Server salvato';
          serverAddress = retrievedSettings.serverAddress;
          serverPort = retrievedSettings.serverPort;
        });
        _setReady(
          ConnectionInfo(
            serverName: 'Server salvato',
            serverAddress: retrievedSettings.serverAddress,
            serverPort: retrievedSettings.serverPort,
          ),
        );
      } else {
        // server not reachable, delete settings and start mDNS
        await localSettingsDB.deleteLocalSettings();
        _startMDNS();
      }
    } else {
      _startMDNS();
    }
  }

  Future<bool> _pingServer(ApiService api) async {
    setState(() {
      _loading = true;
      _mdnsStatus = MDNSStatus.serverPing;
    });

    _mdnsTimer?.cancel();

    try {
      final res = await api.client.get(api.uri("/ping"));

      if (res.statusCode != 200) {
        throw Exception(res.body);
      }

      return true;
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      return false;
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _setReady(ConnectionInfo info) {
    _mdnsTimer?.cancel();

    setState(() {
      _mdnsStatus = MDNSStatus.ready;
      _loading = false;
      _error = null;
    });

    Provider.of<MainState>(context, listen: false).connectionInfo = info;
  }

  Future<void> _startMDNS() async {
    _stopMDNS();

    setState(() {
      _loading = true;
      _mdnsStatus = MDNSStatus.mdnsDiscovery;
    });

    // TODO in futuro cambia hard-coded timeout
    _mdnsTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (_mdnsStatus == MDNSStatus.mdnsDiscovery) {
          const error = 'Server mDNS non trovato';
          _stopMDNS();
          setState(() {
            _mdnsStatus = MDNSStatus.manualPing;
            _error = error;
            _loading = false;
          });

          showPlatformDialog(
            context: context,
            builder: (context) => InsertAddressDialog(
              onSuccess: (String address) async {
                await _saveToDB(
                  "Server inserito",
                  address,
                  widget.apiServerPort,
                );
                _setReady(
                  ConnectionInfo(
                    serverName: "Server inserito",
                    serverAddress: address,
                    serverPort: widget.apiServerPort,
                  ),
                );
              },
              pingServer: _pingServer,
              apiServerPort: widget.apiServerPort,
            ),
          );
        }
      },
    );

    BonsoirDiscovery discovery = BonsoirDiscovery(type: widget.mdnsServiceName);
    await discovery.ready;

    discovery.eventStream!.listen((event) async {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        dynamic service = event.service;
        if (service.ip == null) {
          throw Exception('serverAddress is null');
        }

        final canPing = await _pingServer(ApiService(
          info: ConnectionInfo(
            serverName: event.service!.name,
            serverAddress: service.ip,
            serverPort: event.service!.port,
          ),
        ));

        if (canPing) {
          _saveToDB(event.service!.name, service.ip, event.service!.port);
          _stopMDNS();
          _setReady(
            ConnectionInfo(
              serverName: event.service!.name,
              serverAddress: service.ip,
              serverPort: event.service!.port,
            ),
          );
        } else {
          setState(() {
            _error = 'Server API non raggiungibile';
          });
        }
      }
    });

    await discovery.start();

    setState(() {
      _mdnsDiscovery = discovery;
    });
  }

  Future<void> _stopMDNS() async {
    _mdnsTimer?.cancel();

    if (_mdnsDiscovery != null) {
      _mdnsDiscovery!.stop();
      setState(() {
        _mdnsDiscovery = null;
      });
    }
  }

  Future<void> _saveToDB(String name, String address, int port) async {
    setState(() {
      _mdnsStatus = MDNSStatus.dbSave;
      serverName = name;
      serverAddress = address;
      serverPort = port;
      _loading = true;
    });

    final settings = LocalSettings(
      serverAddress: serverAddress!,
      serverPort: serverPort!,
    );
    await localSettingsDB.insertLocalSettings(settings);

    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _stopMDNS();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SharedLayout(
      header: const Text("Connessione mDNS"),
      body: Stack(
        children: [
          Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Image(
                  image: AssetImage('assets/logo.jpg'),
                  width: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ricerca server mDNS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const CircularProgressIndicator()
                else if (_error != null &&
                    (serverAddress == null || serverPort == null))
                  Text('mDNS ${widget.mdnsServiceName} non trovato')
                else if (serverAddress != null)
                  if (serverPort != null)
                    ServerAddressCard(
                      connectionInfo: ConnectionInfo(
                        serverName: serverName,
                        serverAddress: serverAddress!,
                        serverPort: serverPort!,
                      ),
                      type: ServerType.mDNS,
                    )
                  else
                    ServerAddressCard(
                      connectionInfo: ConnectionInfo(
                        serverName: serverName,
                        serverAddress: serverAddress!,
                        serverPort: serverPort!,
                      ),
                      type: ServerType.api,
                    ),
                const SizedBox(height: 5),
                // print status as Stato: <b>[status]<b/>
                if (_mdnsStatus != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Stato: '),
                      Text(
                        getMDNSString(_mdnsStatus),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),
                // print error as Error: <b>[error]<b/>
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Errore: '),
                        Text(
                          _error!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: serverAddress == null ||
                      _loading ||
                      _error != null ||
                      _mdnsStatus != MDNSStatus.ready
                  ? null
                  : FloatingActionButton(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      // set disabled if serverAddress is null
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainManagerPage(
                              serverAddress: serverAddress!,
                              // serverPort: serverPort!,
                              // a noi interessa porta API, non mDNS
                              serverPort: widget.apiServerPort,
                            ),
                          ),
                        );
                      },
                      tooltip: 'Continua',
                      child: const Icon(Icons.arrow_forward),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
