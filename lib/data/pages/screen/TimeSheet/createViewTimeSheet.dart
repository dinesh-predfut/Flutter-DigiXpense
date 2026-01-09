import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:digi_xpense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:intl/intl.dart';
import 'package:digi_xpense/core/comman/widgets/multiselectDropdown.dart';

/// =======================
/// DUMMY MODELS
/// Replace with API models
/// =======================
class ProjectModel {
  final String code;
  final String name;
  ProjectModel(this.code, this.name);
}

class BoardModel {
  final String id;
  final String name;
  BoardModel(this.id, this.name);
}

class TaskModel {
  final String id;
  final String name;
  TaskModel(this.id, this.name);
}

/// =======================
/// LINE ITEM MODEL
/// =======================
class TimeSheetLineItem {
  ProjectModel? project;
  BoardModel? board;
  TaskModel? task;
  TaskModel? taskName;
}

/// =======================
/// MAIN PAGE
/// =======================
class TimeSheetRequestPage extends StatefulWidget {
  const TimeSheetRequestPage({super.key});

  @override
  State<TimeSheetRequestPage> createState() => _TimeSheetRequestPageState();
}

class _TimeSheetRequestPageState extends State<TimeSheetRequestPage> {
  /// =======================
  /// FORM STATE
  /// =======================
  String periodType = 'Weekly';
  DateTimeRange? dateRange;
  final Controller controller = Get.find<Controller>();

  final List<TimeSheetLineItem> lineItems = [TimeSheetLineItem()];

  /// =======================
  /// CONTROLLERS
  /// =======================
  final TextEditingController projectCtrl = TextEditingController();
  final TextEditingController boardCtrl = TextEditingController();
  final TextEditingController taskCtrl = TextEditingController();
  final TextEditingController taskNameCtrl = TextEditingController();

  /// =======================
  /// DROPDOWN DATA (API)
  /// =======================
  final List<ProjectModel> projects = [
    ProjectModel('AUT', 'AutomatedSuite'),
    ProjectModel('HR', 'HR Portal'),
  ];

  final List<BoardModel> boards = [
    BoardModel('B01', 'Sprint Board'),
    BoardModel('B02', 'Bug Board'),
  ];

  final List<TaskModel> tasks = [
    TaskModel('T01', 'Development'),
    TaskModel('T02', 'Testing'),
  ];

  final List<String> periodTypes = [
    'Daily',
    'Weekly',
    'BiWeekly',
    'SemiMonthly',
    'Monthly',
  ];

  /// =======================
  /// UI
  /// =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        title: const Text('Time sheet Request Form'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _topForm(),
                  const SizedBox(height: 16),
                  _actionButtons(),
                  const SizedBox(height: 16),
                  ..._buildLineItems(),
                  _bottomButtons(),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  /// =======================
  /// TOP FORM
  /// =======================
  Widget _topForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _projectDropdown()),
                 const SizedBox(width: 12),
                  Expanded(child: _periodDropdown()),
               
                
              ],
            ),
            const SizedBox(height: 20,),
            InkWell(
                    onTap: _pickDateRange,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date Range *',
                        border: OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(10))),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dateRange == null
                            ? 'Select'
                            : '${DateFormat('dd/MM/yyyy').format(dateRange!.start)} - '
                                  '${DateFormat('dd/MM/yyyy').format(dateRange!.end)}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _projectDropdown() {
    return SearchableMultiColumnDropdownField<Project>(
      labelText:
          AppLocalizations.of(context)!.projectId,
          //  ${isMandatory ? "*" : ""}',
      columnHeaders: [
        AppLocalizations.of(context)!.projectName,
        AppLocalizations.of(context)!.projectId,
      ],
      items: controller.project,
      dropdownWidth: 300,
      controller: controller.projectDropDowncontroller,
      selectedValue: controller.selectedProject,
      validator: (value) {
        if (controller.projectDropDowncontroller.text.isEmpty) {
          return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
        }
        return null;
      },

      // enabled: controller.leaveField.value,
      searchValue: (proj) => '${proj.name} ${proj.code}',
      displayText: (proj) => proj.code,
      onChanged: (proj) {
        controller.projectDropDowncontroller.text = proj!.code;
        setState(() {
          controller.selectedProject = proj;
          if (proj != null) {
            controller.showProjectError.value = false;
          }
        });
      },
      rowBuilder: (proj, searchQuery) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(proj.name)),
              Expanded(child: Text(proj.code)),
            ],
          ),
        );
      },
    );
    
  }
 
Widget _periodDropdown() {
    return SearchableMultiColumnDropdownField<String>(
      labelText:
          "Period Type",
        
      columnHeaders: ["Type"
      ],
      items: periodTypes,
      // controller: controller.projectDropDowncontroller,
      selectedValue: periodType,
      validator: (value) {
        if (controller.projectDropDowncontroller.text.isEmpty) {
          return '${AppLocalizations.of(context)!.projectId} ${AppLocalizations.of(context)!.fieldRequired}';
        }
        return null;
      },

      // enabled: controller.leaveField.value,
      searchValue: (proj) => proj,
      displayText: (proj) => proj,
      onChanged: (proj) {
        // controller.projectDropDowncontroller.text = proj!;
        setState(() {
         periodType=proj!;
        
        });
      },
      rowBuilder: (proj, searchQuery) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(child: Text(proj)),
             
            ],
          ),
        );
      },
    );
    
  }
  /// =======================
  /// ACTION BUTTONS
  /// =======================
  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            setState(() => lineItems.add(TimeSheetLineItem()));
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Line'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {},
          icon: const Icon(Icons.timer),
          label: const Text('Add Timer'),
        ),
      ],
    );
  }

  /// =======================
  /// LINE ITEMS
  /// =======================
  List<Widget> _buildLineItems() {
    return List.generate(lineItems.length, (index) {
      return _lineItem(index);
    });
  }

  Widget _lineItem(int index) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Line Item - ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (lineItems.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => lineItems.removeAt(index));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            /// PROJECT & BOARD
            Row(
              children: [
                Expanded(child: _projectDropdown()),
                const SizedBox(width: 10),
                Expanded(child: _boardDropdown()),
              ],
            ),
            const SizedBox(height: 12),

            /// TASK & TASK NAME
            Row(
              children: [
                Expanded(child: _taskDropdown()),
                const SizedBox(width: 10),
                Expanded(child: _taskNameDropdown()),
              ],
            ),
            const SizedBox(height: 16),

            /// HOURS SCROLLER
            _hourScroller(),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// SEARCHABLE DROPDOWNS
  /// =======================
 
  Widget _boardDropdown() {
    return SearchableMultiColumnDropdownField<BoardModel>(
      labelText: 'Board ID *',
      columnHeaders: const ['ID', 'Name'],
      items: boards,
      controller: boardCtrl,
      dropdownWidth: 300,
      alignLeft: -150,
      displayText: (b) => b.id,
      searchValue: (b) => '${b.id} ${b.name}',
      rowBuilder: (b, _) => Row(
        children: [
          Expanded(child: Text(b.id)),
          Expanded(child: Text(b.name)),
        ],
      ),
      onChanged: (b) {
        boardCtrl.text = b?.id ?? '';
      },
    );
  }

  Widget _taskDropdown() {
    return SearchableMultiColumnDropdownField<TaskModel>(
      labelText: 'Task *',
      columnHeaders: const ['ID', 'Name'],
      items: tasks,
      controller: taskCtrl,
      displayText: (t) => t.id,
      searchValue: (t) => '${t.id} ${t.name}',
      rowBuilder: (t, _) => Row(
        children: [
          Expanded(child: Text(t.id)),
          Expanded(child: Text(t.name)),
        ],
      ),
      onChanged: (t) {
        taskCtrl.text = t?.id ?? '';
      },
    );
  }

  Widget _taskNameDropdown() {
    return SearchableMultiColumnDropdownField<TaskModel>(
      labelText: 'Task Name *',
      columnHeaders: const ['ID', 'Name'],
      items: tasks,
      controller: taskNameCtrl,
      displayText: (t) => t.name,
      searchValue: (t) => '${t.id} ${t.name}',
      rowBuilder: (t, _) => Row(
        children: [
          Expanded(child: Text(t.id)),
          Expanded(child: Text(t.name)),
        ],
      ),
      onChanged: (t) {
        taskNameCtrl.text = t?.name ?? '';
      },
    );
  }

  /// =======================
  /// HOUR SCROLLER
  /// =======================
  Widget _hourScroller() {
    final dates = List.generate(
      7,
      (i) => DateTime.now().add(Duration(days: i)),
    );

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (_, i) {
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('EEE').format(dates[i])),
                Text(
                  DateFormat('dd MMM').format(dates[i]),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Text(
                  '2:00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// =======================
  /// BOTTOM BUTTONS
  /// =======================
  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =======================
  /// DATE PICKER
  /// =======================
  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (result != null) setState(() => dateRange = result);
  }
}
