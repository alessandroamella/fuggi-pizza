import 'package:flutter/material.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:provider/provider.dart';
import 'package:orderer_app/pages/start_mdns.dart';

const String mdnsServiceName = '_fuggipizza._tcp';
const int apiServerPort = 5500;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MainState(),
      child: const OrdererApp(),
    ),
  );
}

class OrdererApp extends StatelessWidget {
  const OrdererApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuggi Pizza Cameriere',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
      ),
      home: const StartPage(
        mdnsServiceName: mdnsServiceName,
        apiServerPort: apiServerPort,
      ),
    );
  }
}
