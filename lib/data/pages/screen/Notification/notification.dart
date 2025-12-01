import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  final controller = Get.put(Controller());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize TabController with Unread first
    _tabController = TabController(length: 2, vsync: this);

    // Fetch notifications after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
       final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: const Color(0xFFEFEFF1),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              // Reactive data based on selected tab
              final notifications = _tabController.index == 0
                  ? controller.unreadNotifications
                  : controller.notifications;

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications found.'));
              }

              return _buildNotificationList(notifications);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
       final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      height: 140,
      decoration:  BoxDecoration(
       color: theme.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
           Text(
            AppLocalizations.of(context)!.notifications,
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: TabBar(
        controller: _tabController,
        onTap: (_) {
          setState(() {}); // Refresh UI on tab change
        },
        indicatorColor: Theme.of(context).colorScheme.secondary,
        labelColor: Theme.of(context).colorScheme.secondary,
        unselectedLabelColor: Colors.grey,
        tabs:  [
          Tab(text: AppLocalizations.of(context)!.unread,), // Swapped tab labels
          Tab(text: AppLocalizations.of(context)!.allNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            if (!item.read) {
              _showMessageDialog(
                  item.notificationName, item.notificationMessage);
              controller.markAsRead(item);
            } else {
              _showMessageDialog(
                  item.notificationName, item.notificationMessage);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.read
                  ? const Color.fromARGB(255, 177, 174, 174)
                  : const Color.fromARGB(185, 195, 224, 238),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.notificationName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  item.notificationMessage,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd/MMM/yyyy, HH:mm:ss')
                      .format(item.createdDatetime),
                  style: const TextStyle(
                    fontSize: 12,
                    // fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formattedDate(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    return DateFormat('dd/MMM/yyyy, HH:mm:ss').format(date);
  }

  /// Format timestamp or ISO date string from response
  String formatDateTime(dynamic timestamp) {
    try {
      if (timestamp == null) return '';

      // Debug: see what type/value backend gives
      debugPrint("📥 Raw timestamp: $timestamp (${timestamp.runtimeType})");

      DateTime date;

      if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      } else if (timestamp is String) {
        date =
            DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)).toLocal();
      } else if (timestamp is double) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()).toLocal();
      } else {
        return '';
      }

      return DateFormat("dd/MMM/yyyy, HH:mm:ss").format(date);
    } catch (e) {
      debugPrint("❌ Error parsing date: $e");
      return '';
    }
  }

  /// Show popup dialog for notification message
  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
                            controller.closeField();
                            Navigator.pop(context);
                          },
            child:  Text(AppLocalizations.of(context)!.close),
          )
        ],
      ),
    );
  }
}
