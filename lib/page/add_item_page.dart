import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for FilteringTextInputFormatter
import '../../model/database_helper.dart';
import 'package:image_picker/image_picker.dart';

import '/model/item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _photo = '';

  final ImagePicker _picker = ImagePicker();

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

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      Item newItem = Item(
        name: _nameController.text,
        photo: _photo,
        category: _categoryController.text,
        price: int.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );

      await DatabaseHelper.instance.insertItem(newItem);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Tambah Barang Baru',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme:
        const IconThemeData(color: Colors.white), // Set icon color to white
        centerTitle: true, // Center the title
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: _photo.isNotEmpty
                          ? DecorationImage(
                        image: MemoryImage(base64Decode(_photo)),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _photo.isEmpty
                        ? const Icon(Icons.camera_alt, size: 60)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama barang tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // Only allow digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    // No need for int.tryParse here, inputFormatters ensure only digits
                    return null;
                  },
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly // Only allow digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    // No need for int.tryParse here, inputFormatters ensure only digits
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange, // Set text color to white
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}