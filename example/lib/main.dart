import 'package:flutter/material.dart';
import 'package:dropdown_overlay/dropdown_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Simple Dropdown Example'),
        ),
        body: const Center(
          child: DropdownExample(),
        ),
      ),
    );
  }
}

class DropdownExample extends StatefulWidget {
  const DropdownExample({super.key});

  @override
  State<DropdownExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  final _singleSelectionController = DropdownController<String>.single(
    items: List.generate(
      15,
      (index) => DropdownItem(value: "Single $index"),
    ),
  );
  final _multiSelectionController = DropdownController<String>.multi(
    items: List.generate(
      15,
      (index) => DropdownItem(value: "Multi $index"),
    ),
  );

  final _singleSearchController = DropdownController<String>.single(
    items: List.generate(
      15,
      (index) => DropdownItem(value: "Single Search $index"),
    ),
  );

  final _multiSearchController = DropdownController<String>.multi(
    items: List.generate(
      15,
      (index) => DropdownItem(value: "Multi Search $index"),
    ),
  );

  final TextEditingController _singleSearch = TextEditingController();
  final TextEditingController _multiSearch = TextEditingController();

  @override
  void dispose() {
    _singleSelectionController.dispose();
    _multiSelectionController.dispose();
    _singleSearchController.dispose();
    _multiSearchController.dispose();

    _singleSearch.dispose();
    _multiSearch.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          SimpleDropdown<String>.list(
            controller: _singleSelectionController,
            builder: (_) => Container(
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Single Select"),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            menuPosition: const DropdownMenuPosition(
              offset: Offset(0, 10),
            ),
            menuConstraints: const BoxConstraints(
              maxHeight: 150,
            ),
            itemBuilder: (_, item) => GestureDetector(
              onTap: () {
                _singleSelectionController.select(item.value, dismiss: false);
              },
              child: Card(
                color: item.selected ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(item.value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          SimpleDropdown<String>.list(
            controller: _multiSelectionController,
            builder: (_) => Container(
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Multi Select"),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            menuPosition: const DropdownMenuPosition(
              offset: Offset(0, 5),
            ),
            menuConstraints: const BoxConstraints(
              maxHeight: 150,
            ),
            itemBuilder: (_, item) => GestureDetector(
              onTap: () {
                _multiSelectionController.select(item.value, dismiss: false);
              },
              child: Card(
                color: item.selected ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(item.value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Divider(),
          const SizedBox(height: 50),
          SimpleDropdown<String>.list(
            controller: _singleSearchController,
            builder: (_) => SizedBox(
              width: 150,
              child: TextField(
                controller: _singleSearch,
                decoration: const InputDecoration(
                  labelText: "Single Search",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (!_singleSearchController.isOpen) {
                    _singleSearchController.open();
                  }

                  if (value.isEmpty) {
                    _singleSearchController.restore();
                  } else {
                    _singleSearchController.search(
                      value,
                      matcher: (query, item) => item.contains(query),
                    );
                  }
                },
              ),
            ),
            menuPosition: const DropdownMenuPosition(
              offset: Offset(0, 5),
            ),
            menuConstraints: const BoxConstraints(
              maxHeight: 150,
            ),
            itemBuilder: (_, item) => GestureDetector(
              onTap: () {
                _singleSearchController.select(item.value, dismiss: false);
              },
              child: Card(
                color: item.selected ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(item.value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          SimpleDropdown<String>.list(
            controller: _multiSearchController,
            builder: (_) => SizedBox(
              width: 150,
              child: TextField(
                controller: _multiSearch,
                decoration: const InputDecoration(
                  labelText: "Multi Search",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (!_multiSearchController.isOpen) {
                    _multiSearchController.open();
                  }
                  if (value.isEmpty) {
                    _multiSearchController.restore();
                  } else {
                    _multiSearchController.search(
                      value,
                      matcher: (query, item) => item.contains(query),
                    );
                  }
                },
              ),
            ),
            menuPosition: const DropdownMenuPosition(
              targetAnchor: Alignment.topLeft,
              anchor: Alignment.bottomLeft,
              offset: Offset(0, -5),
            ),
            menuConstraints: const BoxConstraints(
              maxHeight: 150,
            ),
            itemBuilder: (_, item) => GestureDetector(
              onTap: () {
                _multiSearchController.select(item.value, dismiss: false);
              },
              child: Card(
                color: item.selected ? Colors.green : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(item.value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          TextButton(
            onPressed: () {
              _multiSearchController.load(
                () => List.generate(
                  5,
                  (index) => DropdownItem(value: "Load More $index"),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text("Load More"),
          ),
        ],
      ),
    );
  }
}
