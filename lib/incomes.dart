// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  IncomeScreenState createState() => IncomeScreenState();
}

class IncomeScreenState extends State<IncomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> incomes = [];
  double totalIncomes = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    QuerySnapshot incomeSnapshot = await _firestore.collection('incomes').doc(uid).collection('my_incomes').get();
    List<Map<String, dynamic>> data = incomeSnapshot.docs.map((doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      docData['id'] = doc.id;
      return docData;
    }).toList();
    double totalIncome = incomeSnapshot.docs.fold(
        0, (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['amount']);

    setState(() {
      incomes = data;
      totalIncomes = totalIncome;
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
              await _firestore.collection('incomes').doc(uid).collection('my_incomes').add({
                'name': name,
                'amount': amount,
                'timestamp': Timestamp.now()
              });
              Navigator.of(context).pop();
              _fetchIncomes();
            },
            child: const Text('Add', style: TextStyle(color: Colors.green),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );
  }

  Future<void> _editIncome(
      String id, String currentName, double currentAmount) async {
    TextEditingController _nameController =
        TextEditingController(text: currentName);
    TextEditingController _amountController =
        TextEditingController(text: currentAmount.toString());
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
              await _firestore.collection('incomes').doc(uid).collection('my_incomes').doc(id).update({
                'name': name,
                'amount': amount,
                'timestamp': Timestamp.now()
              });
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
    await _firestore.collection('incomes').doc(uid).collection('my_incomes').doc(id).delete();
    _fetchIncomes(); // Refresh the list
  }

  final constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.primaryColor,
        title: Text(
          'Source of Fund',
          style: constants.headerText,
        ),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title:  Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              color: constants.primaryColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                ' Funds',
                                style: TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _addIncome();
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ))
                            ],
                          )),
            children: [
              ...incomes.map((income) => ListTile(
                    title: Text('${income['name']}           ${income['amount']}', 
                    style: constants.normalFont,),
                   
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          color: Colors.amber,
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editIncome(
                              income['id'], income['name'], income['amount']),
                        ),
                        IconButton(
                          color: Colors.red,
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteIncome(income['id']),
                        ),
                      ],
                    ),
                  )),
              // TextButton(
              //   onPressed: _addIncome,
              //   child: const Text('Add Income'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
