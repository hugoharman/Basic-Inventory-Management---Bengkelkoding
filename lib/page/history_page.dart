import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import '../../model/database_helper.dart';
import 'package:intl/intl.dart';

import '../model/history.dart';
import '../model/item.dart';

class HistoryPage extends StatefulWidget {
  final Item item;

  const HistoryPage({Key? key, required this.item}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  String _transactionType = 'Masuk';
  DateTime _selectedDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _saveHistory() async {
    if (_formKey.currentState!.validate()) {
      // No need for try-catch here, input is already validated as a number
      int quantity = int.parse(_quantityController.text);

      if (_transactionType == 'Keluar' && widget.item.stock < quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stok tidak cukup!'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Use try-catch for database operations
      try {
        History newHistory = History(
          itemId: widget.item.id!,
          itemName: widget.item.name,
          type: _transactionType,
          quantity: quantity,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        );

        await DatabaseHelper.instance.insertHistory(newHistory);

        if (_transactionType == 'Masuk') {
          widget.item.stock += quantity;
        } else {
          widget.item.stock -= quantity;
        }
        await DatabaseHelper.instance.updateItem(widget.item);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Riwayat berhasil disimpan!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Clear the form
        _quantityController.clear();
        setState(() {
          _selectedDate = DateTime.now();
        });

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving history: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          'Tambah Riwayat Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _transactionType,
                decoration:
                const InputDecoration(labelText: 'Jenis Transaksi'),
                items: ['Masuk', 'Keluar']
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _transactionType = value!;
                  });
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange,
                    ),
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ScaleTransition(
                scale: _scaleAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveHistory();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}