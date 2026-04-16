
import 'package:diginexa/data/models.dart';
import 'package:diginexa/data/service.dart';
import 'package:diginexa/l10n/app_localizations.dart';
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
  final controller = Get.find<Controller>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // ✅ Rebuild when tab changes
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUnreadNotifications();
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
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding:
          const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
      height: 140,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(30)),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // ✅ Mark all as read button
          Obx(() {
            if (controller.unreadCount.value == 0) return const SizedBox();
            return TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
              label: const Text(
                'Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= TAB BAR =================
  Widget _buildTabBar() {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        child: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.unread),
                  const SizedBox(width: 6),
                 
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.allNotifications),
                  const SizedBox(width: 6),
                  if (controller.notifications.isNotEmpty)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey.shade400,
                      child: Text(
                        controller.notifications.length > 99
                            ? '99+'
                            : controller.notifications.length.toString(),
                        style: const TextStyle(
                            fontSize: 9, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ================= BODY =================
  Widget _buildBody() {
    return Obx(() {
      final isUnreadTab = _tabController.index == 0;

      final list = isUnreadTab
          ? controller.unreadNotifications
          : controller.notifications;

      final isLoading = isUnreadTab
          ? controller.isLoadingUnread.value   // ✅ correct flag
          : controller.isLoadingAll.value;     // ✅ correct flag

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (list.isEmpty) {
        return _buildEmptyState(isUnreadTab);
      }

      return RefreshIndicator(
        onRefresh: () async {
          if (isUnreadTab) {
            await controller.fetchUnreadNotifications();
          } else {
            await controller.fetchUnreadNotifications();
          }
        },
        child: _buildNotificationList(list, isUnreadTab),
      );
    });
  }

  // ================= EMPTY STATE =================
  Widget _buildEmptyState(bool isUnread) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnread ? Icons.mark_email_read : Icons.notifications_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            isUnread
                ? "You're all caught up!"
                : "No notifications found",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isUnread
                ? "No unread notifications"
                : "Pull down to refresh",
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ================= LIST =================
  Widget _buildNotificationList(
      List<NotificationModel> items, bool isUnreadTab) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return _buildNotificationCard(item, isUnreadTab);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel item, bool isUnreadTab) {
    return Dismissible(
      key: ValueKey('${item.recId}_${item.read}'),
      // ✅ Only allow swipe on unread tab unread items
      direction: (!item.read && isUnreadTab)
          ? DismissDirection.endToStart
          : DismissDirection.none,
      confirmDismiss: (direction) async {
        controller.markAsRead(item);
        setState(() {
          
        });
        return false; // ✅ Don't remove from list — let controller handle it
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Mark read',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.check, color: Colors.white),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _showMessageDialog(
              item.notificationName, item.notificationMessage);
          if (!item.read) {
            controller.markAsRead(item);
             setState(() {
          
        });
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.read
                ? Colors.grey.shade100
                : Theme.of(context).primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.read
                  ? Colors.grey.shade300
                  : Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Avatar with read/unread state
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: item.read
                        ? Colors.grey.shade400
                        : Theme.of(context).primaryColor,
                    child: const Icon(Icons.notifications,
                        color: Colors.white),
                  ),
                  if (!item.read)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // ✅ Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.notificationName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.read
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        // ✅ Time on right
                        Text(
                          _formatTime(item.createdDatetime),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notificationMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.read
                            ? Colors.grey[600]
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(item.createdDatetime),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Smart time formatter
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }

  // ✅ Mark all as read
  Future<void> _markAllAsRead() async {
    final unread = List<NotificationModel>.from(
        controller.unreadNotifications);
    for (final item in unread) {
      if (!item.read) {
        controller.markAsRead(item);
         setState(() {
          
        });
      }
    }
  }

  // ================= DIALOG =================
  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications,
                color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              controller.closeField();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}