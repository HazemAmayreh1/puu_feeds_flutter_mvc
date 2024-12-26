import 'package:flutter/material.dart';
import '/controllers/subscriptions_controller.dart';
import '/models/subscription.dart';

class SubscriptionsPage extends StatefulWidget {
  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final SubscriptionsController controller = SubscriptionsController();
  bool isLoading = true;
  List<Subscription> subscriptions = [];

  @override
  void initState() {
    super.initState();
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    try {
      List<Subscription> loadedSubscriptions = await controller.fetchSubscriptions();
      setState(() {
        subscriptions = loadedSubscriptions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscriptions'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade700, Colors.blueAccent.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : subscriptions.isEmpty
                ? Center(child: Text('No subscriptions found.'))
                : ListView.builder(
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = subscriptions[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 50, color: Colors.indigo),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subscription.section,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Course: ${subscription.course}',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Lecturer: ${subscription.lecturer}',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                    ),
                                     SizedBox(height: 8),
                                    Text(
                                      'Collage: College Of IT and Computer Engineering',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                    ),
                                    
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text(
                                          subscription.subscriptionDate,
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
