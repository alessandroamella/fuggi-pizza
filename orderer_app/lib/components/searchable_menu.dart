import 'package:flutter/material.dart';
import 'package:orderer_app/misc/order.dart';

class SearchableMenu extends StatefulWidget {
  final Function(Dish)? onSelect;
  final Function(Dish)? onRemove;
  final List<Dish> dishes;
  final List<OrderedDish>? orderedDishes;

  const SearchableMenu({
    super.key,
    required this.onSelect,
    required this.onRemove,
    required this.dishes,
    this.orderedDishes,
  });

  @override
  State<StatefulWidget> createState() => _SearchableMenu();
}

class _SearchableMenu extends State<SearchableMenu> {
  late List<Dish> _dishes;
  late List<Dish> _filteredDishes;
  List<int> _categoryIndexes = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dishes = widget.dishes;
    _filteredDishes = _dishes;
    // ordina prima per nome
    _dishes.sort((a, b) => a.name.compareTo(b.name));
    // poi per categoria
    _dishes.sort((a, b) => a.category.name.compareTo(b.category.name));
    setDividerIndex();
  }

  void setDividerIndex() {
    setState(() {
      _categoryIndexes = [];
      for (int i = 1; i < _filteredDishes.length; i++) {
        if (_filteredDishes[i].category.name !=
            _filteredDishes[i - 1].category.name) {
          _categoryIndexes.add(i);
        }
      }
    });
  }

  void search(String query) {
    setState(() {
      _filteredDishes = query.isEmpty
          ? _dishes
          : _dishes
              .where((item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
    setDividerIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: search,
            decoration: InputDecoration(
              hintText: 'Cerca piatto',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        if (_filteredDishes.isEmpty)
          const Center(
            child: Text(
              'Nessun risultato',
              style: TextStyle(fontSize: 18),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _filteredDishes.length,
              separatorBuilder: (BuildContext context, int index) {
                if (index < _filteredDishes.length &&
                    _categoryIndexes.contains(index + 1)) {
                  return ListDivider(
                      index, _filteredDishes[index + 1].category.name);
                }
                return Container();
              },
              itemBuilder: (context, index) {
                final item = _filteredDishes[index];

                final amount = widget.orderedDishes == null ||
                        widget.orderedDishes!
                            .every((element) => element.dish.id != item.id)
                    ? 0
                    : widget.orderedDishes!
                        .where((element) => element.dish.id == item.id)
                        .fold<int>(
                          0,
                          (previousValue, element) =>
                              previousValue + element.quantity,
                        );

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('€${(item.price / 100).toStringAsFixed(2)}'),
                  onLongPress: () {
                    FocusScope.of(context).unfocus();
                    searchController.clear();
                    search('');
                    if (widget.onRemove != null) {
                      widget.onRemove!(item);
                    }
                  },
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    searchController.clear();
                    search('');
                    if (widget.onSelect != null) {
                      widget.onSelect!(item);
                    }
                  },
                  trailing: amount == 0
                      ? null
                      : CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            amount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                );
              },
            ),
          )
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Column ListDivider(int index, String category) {
    return Column(
      children: [
        const Divider(
          indent: 72,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
