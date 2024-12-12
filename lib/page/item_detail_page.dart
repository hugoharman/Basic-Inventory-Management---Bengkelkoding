import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../model/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'history_page.dart';
import '../model/history.dart';
import 'package:intl/intl.dart';

import '../model/item.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.item});

  final Item item;

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late String _photo;
  List<History> _history = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _priceController =
        TextEditingController(text: widget.item.price.toString());
    _stockController =
        TextEditingController(text: widget.item.stock.toString());
    _photo = widget.item.photo;
    _loadHistory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _photo = base64Encode(imageBytes);
      });
    }
  }

  void _updateItem() async {
    Item updatedItem = Item(
      id: widget.item.id,
      name: _nameController.text,
      photo: _photo,
      category: _categoryController.text,
      price: int.parse(_priceController.text),
      stock: int.parse(_stockController.text),
    );

    await DatabaseHelper.instance.updateItem(updatedItem);

    Navigator.pop(context, true);
  }

  void _deleteItem() async {
    await DatabaseHelper.instance.deleteItem(widget.item.id!);

    Navigator.pop(context, true);
  }

  Future<void> _loadHistory() async {
    List<History> history =
    await DatabaseHelper.instance.getHistoryForItem(widget.item.id!);
    setState(() {
      _history = history;
    });
  }

  Future<void> _deleteHistory(History history) async {
    int currentStockChange = history.type == 'Masuk' ? -history.quantity : history.quantity;

    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        int quantityToDelete = history.quantity;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Hapus Riwayat'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
                  const SizedBox(height: 16),

                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Hapus'),
                  onPressed: () async {
                    int stockChange = history.type == 'Masuk' ? -quantityToDelete : quantityToDelete;
                    widget.item.stock += stockChange;

                    if (quantityToDelete < history.quantity) {
                      History updatedHistory = History(
                        id: history.id,
                        itemId: history.itemId,
                        itemName: history.itemName,
                        type: history.type,
                        quantity: history.quantity - quantityToDelete,
                        date: history.date,
                      );
                      await DatabaseHelper.instance.updateHistory(updatedHistory);
                    } else {
                      await DatabaseHelper.instance.deleteHistory(history.id!);
                    }

                    await DatabaseHelper.instance.updateItem(widget.item);

                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldDelete == true) {
      _loadHistory();
      _loadItems();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    if (_photo.isNotEmpty) {
      imageBytes = base64Decode(_photo);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(widget.item.name,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme:
        IconThemeData(color: Colors.white), // Set icon color to white
        centerTitle: true, // Center the title
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Detail Barang'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Nama: ${_nameController.text}'),
                      Text('Kategori: ${_categoryController.text}'),
                      Text('Harga: ${_priceController.text}'),
                      Text('Stok: ${_stockController.text}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup', style: TextStyle(color: Colors.deepOrange)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text(
                      'Apakah Anda yakin ingin menghapus barang ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteItem();
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Hero(
                  tag: 'itemImage-${widget.item.name}',
                  child: Center(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: imageBytes != null
                            ? DecorationImage(
                          image: MemoryImage(imageBytes),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: imageBytes == null
                          ? const Icon(Icons.camera_alt, size: 60)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _updateItem,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange, // Set text color to white
                  ),
                  child: const Text('Update'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(item: widget.item),
                      ),
                    ).then((value) {
                      if (value == true) {
                        // Stock was updated
                        _loadHistory(); // Refresh history
                        _loadItems();
                        setState(() {
                          // Refresh item details (stock might have changed)
                          widget.item.stock = int.parse(_stockController.text);
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text('Tambah Riwayat'),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('Riwayat Barang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              _history.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tidak ada riwayat barang.'),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final history = _history[index];
                  return ListTile(
                    title: Text(
                        '${history.type} (${history.quantity}) - ${history.itemName}'),
                    subtitle: Text(
                        'Tanggal: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(history.date))}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteHistory(history);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _loadItems() async {
    List<Item> items = await DatabaseHelper.instance.getItems();
    setState(() {
      items = items;
    });
  }
}