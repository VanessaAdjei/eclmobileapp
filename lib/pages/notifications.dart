import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomnav.dart';
import 'cart.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, List<Map<String, String>>> groupedNotifications = {};


  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _addSampleNotifications();
  }


  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    if (keys.isNotEmpty) {
      keys.forEach((key) {
        List<String>? notificationStrings = prefs.getStringList(key);
        if (notificationStrings != null) {
          List<Map<String, String>> notifications = notificationStrings
              .map((item) => Map<String, String>.from(jsonDecode(item)))
              .toList();
          groupedNotifications[key] = notifications;
        }
      });
      setState(() {});
    }
  }

  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    groupedNotifications.forEach((date, notifications) {
      List<String> notificationStrings = notifications.map((notif) => jsonEncode(notif)).toList();
      prefs.setStringList(date, notificationStrings);
    });
  }


  void _addSampleNotifications() {
    if (groupedNotifications.isNotEmpty) return;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("EEEE, MMM d").format(now);

    setState(() {
      if (groupedNotifications.length > 10) {
        groupedNotifications.remove(groupedNotifications.keys.first);
      }

      groupedNotifications.putIfAbsent(formattedDate, () => []);


      groupedNotifications[formattedDate]?.add({
        'title': 'Order Confirmation',
        'message': 'Your order for Pain Relief Tablets has been confirmed and is being processed. You will receive a tracking number soon.',
        'time': '2:15 PM',
        'expanded': 'false',
        'read': 'false',
      });

      groupedNotifications[formattedDate]?.add({
        'title': 'Shipping Update',
        'message': 'Your order has been shipped and is on its way! Track your package with the tracking number provided.',
        'time': '3:45 PM',
        'expanded': 'false',
        'read': 'false',
      });

      groupedNotifications[formattedDate]?.add({
        'title': 'Product Available',
        'message': 'The Vitamin D3 Supplement you requested is now back in stock! Order now before it runs out again.',
        'time': '9:00 AM',
        'expanded': 'false',
        'read': 'false',
      });

      groupedNotifications[formattedDate]?.add({
        'title': 'Order Delivered',
        'message': 'Your order has been delivered. Thank you for shopping with us! We hope you enjoy your purchase.',
        'time': '5:30 PM',
        'expanded': 'false',
        'read': 'false',
      });

      groupedNotifications[formattedDate]?.add({
        'title': 'Restock Reminder',
        'message': 'It\'s time to refill your prescription for Blood Pressure Medication. Order now to avoid running out.',
        'time': '8:00 AM',
        'expanded': 'false',
        'read': 'false',
      });

      groupedNotifications[formattedDate]?.add({
        'title': 'Payment Successful',
        'message': 'Your payment for the order Pain Relief Bundle has been successfully processed. Thank you!',
        'time': '2:50 PM',
        'expanded': 'false',
        'read': 'false',
      });


      groupedNotifications[formattedDate]?.add({
        'title': 'Order Cancellation',
        'message': 'Your order for Cough Syrup has been canceled due to an issue with payment. Please check your payment details.',
        'time': '6:30 PM',
        'expanded': 'false',
        'read': 'false',
      });

      groupedNotifications[formattedDate]?.add({
        'title': 'Order Status Update',
        'message': 'Your order is currently being processed. We will notify you once it ships.',
        'time': '7:45 PM',
        'expanded': 'false',
        'read': 'false',
      });
    });

    _saveNotifications();
  }



  void _toggleExpand(String group, int index) {
    setState(() {
      bool isCurrentlyExpanded = groupedNotifications[group]?[index]['expanded'] == 'true';
      groupedNotifications[group]?[index]['expanded'] = isCurrentlyExpanded ? 'false' : 'true';
      groupedNotifications[group]?[index]['read'] = 'true';
    });

    _saveNotifications();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[400],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[700],

              ),
              child:          IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Cart(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        body: groupedNotifications.isNotEmpty
            ? ListView(
          padding: const EdgeInsets.all(16.0),
          children: groupedNotifications.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ...entry.value.asMap().entries.map((notification) {
                  int index = notification.key;
                  return _buildNotificationTile(entry.key, index, notification.value);
                }).toList(),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        )
            : Center(child: Text("No notifications")),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildNotificationTile(String group, int index, Map<String, String> notification) {
    bool isExpanded = notification['expanded'] == 'true';
    bool isRead = notification['read'] == 'true';

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          groupedNotifications[group]?.removeAt(index);
          if (groupedNotifications[group]?.isEmpty ?? false) {
            groupedNotifications.remove(group);
          }
        });
        _saveNotifications();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notification removed')));
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            setState(() {
              if (notification['read'] == 'false') {
                notification['read'] = 'true';
              }
              _toggleExpand(group, index);
            });
            _saveNotifications();
          },


          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification['title']!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message']!,
                  maxLines: isExpanded ? null : 1,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    notification['time']!,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

