import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

class DailyTrackerScreen extends StatefulWidget {
  const DailyTrackerScreen({super.key});

  @override
  DailyTrackerScreenState createState() => DailyTrackerScreenState();
}

class DailyTrackerScreenState extends State<DailyTrackerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> dailyTrackerData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isloading = true;
    });
    QuerySnapshot snapshot = await _firestore.collection('expense_analysis').get();
    List<Map<String, dynamic>> data =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {
      dailyTrackerData = data;
      isloading = false;
    });
  }

  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: LoadingOverlay(
        isLoading: isloading,
        progressIndicator: const CircularProgressIndicator(
          color: Colors.yellow,
        ),
        child: ListView.builder(
          itemCount: dailyTrackerData.length,
          itemBuilder: (context, index) {
            var entry = dailyTrackerData[index];
            return ListTile(
              title: Text('Expense Name: ${entry['expense_name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Entered Amount: \$${entry['entered_amount']}'),
                  Text('Preset Amount: \$${entry['preset_amount']}'),
                  Text('Status: ${entry['is_above'] ? 'Above' : 'Below'}'),
                ],
              ),
              trailing:
                  Text((entry['timestamp'] as Timestamp).toDate().toString()),
            );
          },
        ),
      ),
    );
  }
}
