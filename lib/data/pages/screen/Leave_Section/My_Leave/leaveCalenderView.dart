import 'dart:convert';
import 'package:digi_xpense/data/models.dart' show LeaveDetailsModel, LeaveDetailsModel;
import 'package:digi_xpense/data/service.dart' show Controller;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
  enum MyView { month, week, day }

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

MyView selectedView = MyView.month;
  final controller = Get.put(Controller());
CalendarFormat selectedFormat = CalendarFormat.month;
DateTime _focusedDay = DateTime.now();
DateTime _selectedDay = DateTime.now();
  @override
  void initState() {
    super.initState();
    controller.loadCalendarLeaves();
    // default: today selected
    controller.selectedDay = DateTime.now();
    controller.focusedDay = DateTime.now();
    ;
  }

  // @override
  // void dispose() {
  // controller.dispose();
  // super.dispose();
  // }

  Color _colorFromHex(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('0xFF' + cleaned));
    } catch (e) {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            children: [
              // _buildHeader(),
              // const SizedBox(height: 8),
              // _buildSegmentedControl(),
              const SizedBox(height: 12),
              _buildTableCalendar(),
              const SizedBox(height: 12),
              _buildTodayEventsHeader(),
              const SizedBox(height: 8),
              Expanded(child: _buildBottomList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayEventsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Events",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'View All',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'January 2024',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                
              ],
            ),
          ],
        ),
       
      ],
    );
  }

  Widget _buildSegmentedControl() {
     return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      /// LEFT ARROW BUTTON
    _navButton(Icons.chevron_left, () {
  setState(() {
    if (isDayView) {
      /// Day view → go to previous day
      controller.focusedDay =
          controller.focusedDay.subtract(const Duration(days: 1));
      controller.selectedDay = controller.focusedDay;
    } 
    else if (selectedFormat == CalendarFormat.week) {
      /// Week view → go to previous week
      controller.focusedDay =
          controller.focusedDay.subtract(const Duration(days: 7));
    } 
    else {
      /// Month view → go to previous month
      controller.focusedDay =
          DateTime(controller.focusedDay.year, controller.focusedDay.month - 1, 1);
    }
  });
}),


      /// SEGMENTED CONTROL
      _segmentedControl(),

      /// RIGHT ARROW BUTTON
     _navButton(Icons.chevron_right, () {
  setState(() {
    if (isDayView) {
      /// Day view → go to next day
      controller.focusedDay =
          controller.focusedDay.add(const Duration(days: 1));
      controller.selectedDay = controller.focusedDay;
    } 
    else if (selectedFormat == CalendarFormat.week) {
      /// Week view → go to next week
      controller.focusedDay =
          controller.focusedDay.add(const Duration(days: 7));
    } 
    else {
      /// Month view → go to next month
      controller.focusedDay =
          DateTime(controller.focusedDay.year, controller.focusedDay.month + 1, 1);
    }
  });
})

    ],
  );
  }
Widget _navButton(IconData icon, VoidCallback onTap) {
  return InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5), // light grey
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 24, color: Colors.black87),
    ),
  );
}



/// Segmented control (Month / Week / Day)
Widget _segmentedControl() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F0F5),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _segmentButton("Month", CalendarFormat.month),
        _segmentButton("Week", CalendarFormat.week),
        _segmentButton("Day", CalendarFormat.twoWeeks),
      ],
    ),
  );
}
  Widget _segmentButton(String text, CalendarFormat view) {

  bool isSelected = (selectedFormat == view);

  return InkWell(
    borderRadius: BorderRadius.circular(30),
    onTap: () {
      setState(() {
        selectedFormat = view;
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEBE8FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? const Color(0xFF574BFF) : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
  );
}
bool get isDayView => true;
 

  Widget _buildTableCalendar() {
  return AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TableCalendar<LeaveDetailsModel>( // Specify the type here
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: controller.focusedDay,
              calendarFormat: selectedFormat,
              eventLoader: (date) {
                final key = DateTime(date.year, date.month, date.day);
                return controller.events[key] ?? [];
              },
              selectedDayPredicate: (d) => 
                  isSameDay(d, controller.selectedDay),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(),
                markersAlignment: Alignment.bottomCenter,
                markersMaxCount: 3,
              ),
              calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
  if (events.isEmpty) return const SizedBox.shrink();

  final dots = <String>[];
  for (final e in events.take(3)) {
    // No need to cast, e should already be LeaveDetailsModel
    dots.add(e.leaveColor ?? '#e13333');
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: dots.map((hex) {
      return Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _colorFromHex(hex),
          shape: BoxShape.circle,
        ),
      );
    }).toList(),
  );
},
              ),
              onDaySelected: (selected, focused) {
                controller.onDaySelected(selected, focused);
                setState(() {});
              },
              onPageChanged: (focused) {
                controller.focusedDay = focused;
                setState(() {});
              },
            ),
          ],
        ),
      );
    },
  );
}

 Widget _buildBottomList() {
  final list = controller.selectedEvents;
  if (list.isEmpty) {
    return Center(
      child: Text(
        'No events for ${DateFormat('yMMMd').format(controller.selectedDay)}',
      ),
    );
  }

  return ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, index) {
      final ev = list[index];
      
      final leave = ev; // Now safe to cast
      
      // Convert int timestamps to DateTime
      final fromDate = DateTime.fromMillisecondsSinceEpoch(leave.fromDate);
      final toDate = DateTime.fromMillisecondsSinceEpoch(leave.toDate);
      
      return GestureDetector(
        onTap: () => _openDetail(leave),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: _colorFromHex(leave.leaveColor ?? '#e13333'),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.leaveCode,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      leave.employeeName,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${leave.duration} day${leave.duration != 1 ? 's' : ''}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM d').format(fromDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'to ${DateFormat('MMM d').format(toDate)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      );
    },
  );
}

  void _openDetail(LeaveDetailsModel ev) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeaveDetailPage(transaction: ev)),
    );
  }
}

class LeaveDetailPage extends StatelessWidget {
  final LeaveDetailsModel transaction;
  const LeaveDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fromDate = DateTime.fromMillisecondsSinceEpoch(transaction.fromDate);
DateFormat('yMMMd').format(fromDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _hexToColor('#e13333'),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  transaction.leaveCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row(
              'Date',
              DateFormat('yMMMd').format(fromDate),
            ),
            _row('Approval Status', transaction.approvalStatus),
            _row('No of Days', transaction.duration.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('0xFF' + cleaned));
    } catch (e) {
      return Colors.red;
    }
  }
}
