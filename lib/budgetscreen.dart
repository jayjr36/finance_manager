// ignore_for_file: avoid_types_as_parameter_names

import 'package:finance_manager/constants.dart';
import 'package:finance_manager/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  BudgetScreenState createState() => BudgetScreenState();
}

class BudgetScreenState extends State<BudgetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  Constants constants = Constants();
  double totalExpense = 0.0;
  double totalDailyExpense = 0.0;
  List<Map<String, dynamic>> incomes = [];
  double totalIncome = 0.0;
  @override
  void initState() {
    super.initState();
    _getTotalBudget();
    _fetchIncomes();
    _getTotalDailySpendings();
  }

  Future<void> _addCategory() async {
    final TextEditingController categoryController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(hintText: 'Category Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _firestore
                    .collection('categories')
                    .doc(uid)
                    .collection('my_categories')
                    .add({
                  'name': categoryController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addExpense(String categoryId) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController tallyController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Expense Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tallyController,
                decoration: const InputDecoration(hintText: 'Tally'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                double amount = double.parse(amountController.text);
                int tally = tallyController.text.isNotEmpty
                    ? int.parse(tallyController.text)
                    : 1;
                double totalAmount = amount * tally;

                _firestore
                    .collection('categories')
                    .doc(uid)
                    .collection('my_categories')
                    .doc(categoryId)
                    .collection('expenses')
                    .add({
                  'name': nameController.text,
                  'amount': amount,
                  'tally': tally,
                  'total_amount': totalAmount,
                  'date': DateTime.now(),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editExpense(
      String categoryId, String expenseId, Map<String, dynamic> expense) async {
    final TextEditingController nameController =
        TextEditingController(text: expense['name']);
    final TextEditingController amountController =
        TextEditingController(text: expense['amount'].toString());
    final TextEditingController tallyController =
        TextEditingController(text: expense['tally'].toString());
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Expense Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(hintText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tallyController,
                decoration: const InputDecoration(hintText: 'Tally'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                double amount = double.parse(amountController.text);
                int tally = tallyController.text.isNotEmpty
                    ? int.parse(tallyController.text)
                    : 1;
                double totalAmount = amount * tally;

                _firestore
                    .collection('categories')
                    .doc(uid)
                    .collection('my_categories')
                    .doc(categoryId)
                    .collection('expenses')
                    .doc(expenseId)
                    .update({
                  'name': nameController.text,
                  'amount': amount,
                  'tally': tally,
                  'total_amount': totalAmount,
                  'date': DateTime.now(),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExpense(String categoryId, String expenseId) async {
    _firestore
        .collection('categories')
        .doc(uid)
        .collection('my_categories')
        .doc(categoryId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<double> _getTotalBudget() async {
    double totalBudget = 0.0;

    QuerySnapshot categorySnapshot = await _firestore
        .collection('categories')
        .doc(uid)
        .collection('my_categories')
        .get();

    for (var category in categorySnapshot.docs) {
      QuerySnapshot expenseSnapshot = await _firestore
          .collection('categories')
          .doc(uid)
          .collection('my_categories')
          .doc(category.id)
          .collection('expenses')
          .get();

      for (var expense in expenseSnapshot.docs) {
        totalBudget += expense['total_amount'];
      }
    }
    setState(() {
      totalExpense = totalBudget;
    });

    return totalBudget;
  }

  Future<void> _fetchIncomes() async {
    QuerySnapshot snapshot = await _firestore
        .collection('incomes')
        .doc(uid)
        .collection('my_incomes')
        .get();
    List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      docData['id'] = doc.id;
      return docData;
    }).toList();

    setState(() {
      incomes = data;
      totalIncome = incomes.fold(0, (sum, item) => sum + item['amount']);
    });
  }

  Future<double> _getTotalDailySpendings() async {
    double totalSpendings = 0.0;
    QuerySnapshot dailySpendingsSnapshot = await _firestore
        .collection('daily_spending')
        .doc(uid)
        .collection('my_daily_spending')
        .get();

    for (var spending in dailySpendingsSnapshot.docs) {
      totalSpendings += spending['amount'];
    }
    setState(() {
      totalDailyExpense = totalSpendings;
    });
    return totalSpendings;
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        toolbarHeight: h * 0.15,
        backgroundColor: constants.primaryColor,
        title: ListTile(
          title: Center(child: Image.asset('assets/image1.png')),
          subtitle: Center(child: Image.asset('assets/image2.png')),
        ),
      ),
      body: Column(
        children: [
          Center(
              child: Text(
            "Set Your budget by creating categories",
            style: constants.boldFont,
          )),
          Center(
            child: OutlinedButton(
                onPressed: () {
                  _addCategory();
                },
          
                child: const Text(
                  'New Category',
                  style: TextStyle(color: Colors.green),
                )),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('categories')
                  .doc(uid)
                  .collection('my_categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return ExpansionTile(
                      title: Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              color: constants.primaryColor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '    ${category['name']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _addExpense(category.id);
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ))
                            ],
                          )),
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('categories')
                              .doc(uid)
                              .collection('my_categories')
                              .doc(category.id)
                              .collection('expenses')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final expenses = snapshot.data!.docs;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: expenses.map((expense) {
                                final expenseData =
                                    expense.data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Wrap(
                                    children: [
                                      Text(
                                        '     ${expenseData['name']}',
                                        style: constants.normalFont,
                                      ),
                                      SizedBox(
                                        width: w * 0.2,
                                      ),
                                      Text(
                                        '${expenseData['total_amount']}',
                                        style: constants.normalFont,
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                         color: Colors.amber,
                                        icon: const Icon(
                                          Icons.edit,
                                        ),
                                        onPressed: () => _editExpense(
                                            category.id,
                                            expense.id,
                                            expenseData),
                                      ),
                                      IconButton(
                                         color: Colors.red,
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 15,
                                        ),
                                        onPressed: () => _deleteExpense(
                                            category.id, expense.id),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Center(
              child: Text(
            'SUMMARY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Total Income:     ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                Text('$totalIncome',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromARGB(255, 7, 78, 141)))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Estimated Budget:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$totalExpense',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color.fromARGB(255, 7, 78, 141)),
                    ))
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Amount Spent:       ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$totalDailyExpense',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.red)),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Balance:              ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text('${totalIncome - totalDailyExpense}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.green)))
              ],
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     tooltip: 'Create category',
      //     child: const Icon(Icons.add),
      //     onPressed: () {
      //       _addCategory;
      //     }),
    );
  }
}
