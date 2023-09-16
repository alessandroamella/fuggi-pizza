import 'package:flutter/material.dart';
import 'package:orderer_app/components/searchable_menu.dart';
import 'package:orderer_app/misc/main_state.dart';
import 'package:orderer_app/misc/order.dart';
import 'package:provider/provider.dart';

// used for both creating and editing an order
class SelectDishesPage extends StatefulWidget {
  final Function(List<OrderedDish>) onDishesSelect;
  final List<OrderedDish> selectedDishes;
  final bool isLoading;

  const SelectDishesPage({
    super.key,
    required this.onDishesSelect,
    required this.selectedDishes,
    this.isLoading = false,
  });

  @override
  State<SelectDishesPage> createState() => _SelectDishesPage();
}

class _SelectDishesPage extends State<SelectDishesPage> {
  late Future<List<Dish>> _dishes;

  @override
  void initState() {
    super.initState();
    _dishes = Provider.of<MainState>(context, listen: false).getDishes();
  }

  void incrementOrderedDishQty(Dish dish) {
    List<OrderedDish> selectedDishes = List.from(widget.selectedDishes);
    final index = selectedDishes.indexWhere(
        (element) => element.dish.id == dish.id && element.notes == null);
    if (index != -1) {
      selectedDishes[index].quantity++;
    } else {
      selectedDishes.add(OrderedDish(dish, 1));
    }

    widget.onDishesSelect(selectedDishes);
  }

  final notesController = TextEditingController();

  Widget setDishNotes(BuildContext context, Dish dish) {
    List<OrderedDish> selectedDishes = List.from(widget.selectedDishes);

    selectedDishes.add(OrderedDish(dish, 1));
    final index = selectedDishes.length - 1;

    return AlertDialog(
      title: Text('Inserisci le note per ${dish.name}'),
      content: TextField(
        controller: notesController,
        decoration: const InputDecoration(
          hintText: 'Note',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: () {
            selectedDishes[index].notes = notesController.text;
            widget.onDishesSelect(selectedDishes);
            Navigator.of(context).pop();
          },
          child: const Text('Conferma'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dishes,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Errore: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            return SizedBox(
              height: 500,
              child: SearchableMenu(
                  dishes: snapshot.data as List<Dish>,
                  orderedDishes: widget.selectedDishes,
                  onSelect: widget.isLoading ? null : incrementOrderedDishQty,
                  onRemove: widget.isLoading
                      ? null
                      : (dish) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return setDishNotes(context, dish);
                              });
                        }),
            );
          } else {
            return const Center(
              child: Text('Nessun piatto disponibile'),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}
