import 'package:flutter/material.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:provider/provider.dart';

// used for both creating and editing an order
class SelectTablePage extends StatefulWidget {
  final Function(TableInfo?) onTableSelected;
  final TableInfo? selectedTable;
  final bool isLoading;
  final Function()? nextPage;

  const SelectTablePage({
    super.key,
    required this.onTableSelected,
    required this.selectedTable,
    this.isLoading = false,
    this.nextPage,
  });

  @override
  State<SelectTablePage> createState() => _SelectTablePage();
}

class _SelectTablePage extends State<SelectTablePage> {
  late Future<List<TableInfo>> _tables;

  @override
  void initState() {
    super.initState();
    _tables = Provider.of<MainState>(context, listen: false).getTables();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _tables,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Errore: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData) {
              final tables = snapshot.data as List<TableInfo>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownMenu<TableInfo>(
                    width: MediaQuery.of(context).size.width - 100,
                    dropdownMenuEntries: tables
                        .map((TableInfo table) => DropdownMenuEntry(
                              value: table,
                              label: table.number.toString(),
                            ))
                        .toList(),
                    onSelected: widget.isLoading
                        ? null
                        : (TableInfo? table) {
                            widget.onTableSelected(table);
                          },
                    enableFilter: true,
                    enableSearch: true,
                    hintText: 'Cerca tavolo',
                    initialSelection: widget.selectedTable,
                    label: const Text('Tavolo'),
                    inputDecorationTheme: const InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    leadingIcon: const Icon(Icons.search),
                    trailingIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  if (widget.selectedTable != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        widget.nextPage == null
                            ? RichText(
                                text: TextSpan(
                                  text: 'Tavolo: ',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.selectedTable!.number
                                          .toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // Button Conferma <b>number</b>
                            : ElevatedButton(
                                onPressed: widget.isLoading
                                    ? null
                                    : () {
                                        widget.nextPage!();
                                      },
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Conferma ${widget.selectedTable!.number}',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                      ],
                    ),
                ],
              );
            } else {
              return const Center(
                child: Text('Nessun tavolo disponibile'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
    );
  }
}
