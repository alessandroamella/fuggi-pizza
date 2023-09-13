import 'package:flutter/material.dart';
import 'package:orderer_app/components/address_card.dart';
import 'package:orderer_app/components/layout.dart';
import 'package:orderer_app/pages/main_manager.dart';
import 'package:bonsoir/bonsoir.dart';
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

class _StartPageState extends State<StartPage> {
  bool _loading = false;
  BonsoirDiscovery? mdnsDiscovery;

  final localSettingsDB = LocalSettingsDatabase.instance;

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
    });

    final retrievedSettings = await localSettingsDB.getLocalSettings();

    if (retrievedSettings != null) {
      setState(() {
        _loading = false;
        serverAddress = retrievedSettings.serverAddress;
        serverPort = retrievedSettings.serverPort;
      });
    } else {
      _startMDNS();
    }
  }

  Future<void> _startMDNS() async {
    _stopMDNS();

    setState(() {
      _loading = true;
    });

    BonsoirDiscovery discovery = BonsoirDiscovery(type: widget.mdnsServiceName);
    await discovery.ready;

    discovery.eventStream!.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        dynamic service = event.service;
        if (service.ip == null) {
          throw Exception('serverAddress is null');
        }

        setState(() {
          // cast to dynamic to avoid type error
          serverName = event.service!.name;
          serverAddress = service.ip;
          serverPort = event.service!.port;

          _loading = false;
        });

        // save settings to local db
        final settings = LocalSettings(
          id: 1,
          serverAddress: serverAddress!,
          serverPort: serverPort!,
        );
        localSettingsDB.insertLocalSettings(settings);

        _stopMDNS();
      }
    });

    await discovery.start();

    setState(() {
      mdnsDiscovery = discovery;
    });
  }

  Future<void> _stopMDNS() async {
    if (mdnsDiscovery != null) {
      mdnsDiscovery!.stop();
      setState(() {
        mdnsDiscovery = null;
      });
    }
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
                const SizedBox(height: 5),
                if (_loading)
                  const CircularProgressIndicator()
                else if (serverAddress == null)
                  Text('mDNS ${widget.mdnsServiceName} non trovato')
                else
                  ServerAddressCard(
                    serverName: serverName,
                    serverAddress: serverAddress!,
                    serverPort: serverPort!,
                    type: 'mDNS',
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                backgroundColor:
                    serverAddress == null ? Colors.lightGreen : Colors.green,
                foregroundColor: Colors.white,
                // set disabled if serverAddress is null
                onPressed: serverAddress == null
                    ? null
                    : () {
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
