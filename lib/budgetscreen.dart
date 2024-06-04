import 'package:finance_manager/constants.dart';
import 'package:finance_manager/dailyinput.dart';
import 'package:finance_manager/spendingsbydate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  @override
  void initState() {
    super.initState();
    _getTotalBudget();
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
                _firestore.collection('categories').doc(uid).collection('my_categories').add({
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
    final TextEditingController dateController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
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
                _firestore
                    .collection('categories')
                    .doc(uid)
                    .collection('my_categories')
                    .doc(categoryId)
                    .collection('expenses')
                    .add({
                  'name': nameController.text,
                  'amount': double.parse(amountController.text),
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

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Column(
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
                _firestore
                    .collection('categories')
                    .doc(uid)
                    .collection('my_categories')
                    .doc(categoryId)
                    .collection('expenses')
                    .doc(expenseId)
                    .update({
                  'name': nameController.text,
                  'amount': double.parse(amountController.text),
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

    QuerySnapshot categorySnapshot =
        await _firestore.collection('categories').doc(uid).collection('my_categories').get();

    for (var category in categorySnapshot.docs) {
      QuerySnapshot expenseSnapshot = await _firestore
          .collection('categories')
          .doc(uid)
          .collection('my_categories')
          .doc(category.id)
          .collection('expenses')
          .get();

      for (var expense in expenseSnapshot.docs) {
        totalBudget += expense['amount'];
      }
    }
    setState(() {
      totalExpense = totalBudget;
    });

    return totalBudget;
  }

  Future<double> _getTotalDailySpendings() async {
    double totalSpendings = 0.0;

    QuerySnapshot dailySpendingsSnapshot =
        await _firestore.collection('daily_spendings').doc(uid).collection('my_daily_spendings').get();

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
      appBar: AppBar(
        toolbarHeight: h * 0.15,
        backgroundColor: constants.primaryColor,
        title: ListTile(
          title: Center(child: Image.asset('assets/image1.png')),
          subtitle: Center(child: Image.asset('assets/image2.png')),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          ),
          // IconButton(
          //   icon: const Icon(Icons.calculate),
          //   onPressed: () async {
          //     double totalBudget = await _getTotalBudget();
          //     showDialog<void>(
          //       context: context,
          //       barrierDismissible: false,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: const Text('Total Budget'),
          //           content: Text(
          //               'Total Budget Estimated: \$${totalBudget.toStringAsFixed(2)}'),
          //           actions: <Widget>[
          //             TextButton(
          //               child: const Text('OK'),
          //               onPressed: () {
          //                 Navigator.of(context).pop();
          //               },
          //             ),
          //           ],
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          Center(
              child: Text(
            "Set Your budget by creating categories",
            style: constants.headerText,
          )),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DailySpendingByDateScreen()),
              );
            },
            child: const Text('Spendings By Date'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DailyExpenseScreen()),
              );
            },
            child: const Text('Daily records'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('categories').doc(uid).collection('my_categories').snapshots(),
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
                          // padding: const EdgeInsets.all(4),
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
                                        width: w * 0.3,
                                      ),
                                      Text(
                                        '${expenseData['amount']}',
                                        style: constants.normalFont,
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 15,
                                        ),
                                        onPressed: () => _editExpense(
                                            category.id,
                                            expense.id,
                                            expenseData),
                                      ),
                                      IconButton(
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
                        // ListTile(
                        //   leading: const Icon(Icons.add),
                        //   title: const Text('Add Expense'),
                        //   onTap: () => _addExpense(category.id),
                        // ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Center(child: Text('SUMMARY')),
          Wrap(
            children: [
              const Text('Estimated Expenditure: '),
              Text('$totalExpense')
            ],
          ),
          Wrap(
            children: [const Text('Spent: '), Text('$totalDailyExpense')],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Create category',
          child: const Icon(Icons.add),
          onPressed: () {
            _addCategory;
          }),
    );
  }
}
