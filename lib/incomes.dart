// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  IncomeScreenState createState() => IncomeScreenState();
}

class IncomeScreenState extends State<IncomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> incomes = [];

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    QuerySnapshot snapshot = await _firestore.collection('incomes').get();
    List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      docData['id'] = doc.id; // Add the document ID to the data
      return docData;
    }).toList();

    setState(() {
      incomes = data;
    });
  }

  Future<void> _addIncome() async {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _amountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter income name'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(hintText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text;
              double amount = double.parse(_amountController.text);
              await _firestore.collection('incomes').add({'name': name, 'amount': amount, 'timestamp': Timestamp.now()});
              Navigator.of(context).pop();
              _fetchIncomes(); // Refresh the list
            },
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _editIncome(String id, String currentName, double currentAmount) async {
    TextEditingController _nameController = TextEditingController(text: currentName);
    TextEditingController _amountController = TextEditingController(text: currentAmount.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter income name'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(hintText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text;
              double amount = double.parse(_amountController.text);
              await _firestore.collection('incomes').doc(id).update({'name': name, 'amount': amount, 'timestamp': Timestamp.now()});
              Navigator.of(context).pop();
              _fetchIncomes(); // Refresh the list
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIncome(String id) async {
    await _firestore.collection('incomes').doc(id).delete();
    _fetchIncomes(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Income Tracker', style: TextStyle(color: Colors.white),),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Incomes'),
            children: [
              ...incomes.map((income) => ListTile(
                    title: Text('${income['name']} - \$${income['amount']}'),
                    subtitle: Text((income['timestamp'] as Timestamp).toDate().toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editIncome(income['id'], income['name'], income['amount']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteIncome(income['id']),
                        ),
                      ],
                    ),
                  )),
              TextButton(
                onPressed: _addIncome,
                child: const Text('Add Income'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
