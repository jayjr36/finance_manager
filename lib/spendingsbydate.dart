import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_manager/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailySpendingByDateScreen extends StatefulWidget {
  const DailySpendingByDateScreen({super.key});

  @override
  DailySpendingByDateScreenState createState() => DailySpendingByDateScreenState();
}

class DailySpendingByDateScreenState extends State<DailySpendingByDateScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DateTime? selectedDate;
  List<Map<String, dynamic>> dailySpendings = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchDailySpendings(DateTime date) async {
    Timestamp startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 0, 0, 0));
    Timestamp endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    QuerySnapshot snapshot = await _firestore.collection('daily_spending')
    .doc(uid)
    .collection('my_daily_spending')
      .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
      .where('timestamp', isLessThanOrEqualTo: endOfDay)
      .get();

    setState(() {
      dailySpendings = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchDailySpendings(picked);
    }
  }
final constants = Constants();

String _formatTimestamp(Timestamp timestamp) {
  final DateTime dateTime = timestamp.toDate().toLocal();
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  return formatter.format(dateTime);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: constants.primaryColor,
        title:Text('Daily Spendings by Date', style: constants.headerText,),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Select a date'
                        : 'Selected Date: ${DateFormat.yMMMd().format(selectedDate!)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 15,),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
          const Divider(),
          dailySpendings.isEmpty
              ? const Center(child: Text('No spendings for the selected date'))
              : Expanded(
                  child: ListView.builder(
                    itemCount: dailySpendings.length,
                    itemBuilder: (context, index) {
                      final spending = dailySpendings[index];
                      return ListTile(
                        title: Text('${spending['name']} - ${spending['amount'].toStringAsFixed(2)}'),
                        subtitle: Text(_formatTimestamp(spending['timestamp']) ),
                      );
                    },
                  ),
                ),
        ],
      ),
      
    );
  }
}
