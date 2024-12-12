import 'package:flutter/material.dart';
import '../model/database_helper.dart';
import 'add_item_page.dart';
import '../model/item.dart';
import '../widgets/animated_item_card.dart';
import '../widgets/animated_floating_action_button.dart';
import 'item_detail_page.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    List<Item> items = await DatabaseHelper.instance.getItems();
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Daftar Barang',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _items.isEmpty
            ? const Center(
          child: Text(
            'Tidak ada barang yang tersimpan.',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AnimatedItemCard(
                item: item,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) {
                        return ItemDetailPage(item: item);
                      },
                      transitionsBuilder: (context, animation,
                          secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  ).then((value) {
                    if (value == true) {
                      _loadItems();
                    }
                  });
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddItemPage(),
            ),
          ).then((value) {
            if (value == true) {
              _loadItems();
            }
          });
        },
      ),
    );
  }
}