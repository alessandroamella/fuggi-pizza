import 'package:flutter/material.dart';

class SharedLayout extends StatelessWidget {
  final Widget header;
  final Widget? footer;
  final Widget body;
  final Widget? floatingActionButton;

  const SharedLayout({
    super.key,
    required this.header,
    this.footer,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: header,
        leading: const Icon(Icons.restaurant),
      ),
      body: Column(
        children: [
          Expanded(
            child: body,
          ),
          footer ?? Container(),
        ],
      ),
      // bottomNavigationBar: Container(
      //   color: Colors.grey[800],
      //   padding: const EdgeInsets.all(10.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: const [
      //       Text(
      //         '© Alessandro Amella',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontSize: 16.0,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: floatingActionButton,
    );
  }
}
