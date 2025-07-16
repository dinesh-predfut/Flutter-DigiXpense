import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

    // Initialize TabController
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF1),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              // Reactive data based on selected tab
              final notifications = _tabController.index == 1
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
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      height: 140,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1C44), Color(0xFF2E3C85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Notifications',
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
        indicatorColor: Colors.deepPurple,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: "All Notifications"),
          Tab(text: "Unread"),
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
            controller.markAsRead(item); // Mark notification as read
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.read ? Colors.white : const Color(0xFFF1F2F6),
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
                const Text(
                  // formatDateTime(item.createdDatetime),
                  "",
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Format timestamp to readable date
  String formatDateTime( timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
