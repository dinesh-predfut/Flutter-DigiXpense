import 'package:digi_xpense/core/comman/widgets/searchDropown.dart';
import 'package:digi_xpense/core/constant/Parames/colors.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';
import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MileageFirstFrom extends StatefulWidget {
  const MileageFirstFrom({super.key});

  @override
  State<MileageFirstFrom> createState() => _MileageFirstFromState();
}

class _MileageFirstFromState extends State<MileageFirstFrom> with SingleTickerProviderStateMixin {
  final controller = Get.put(Controller());
  String selectedProject = '';
  final List<String> projectList = ['Project A', 'Project B', 'Project C'];
  @override
  void initState() {
    super.initState();
    controller.fetchProjectName();
  }
  // @override
  // void dispose() {
  //   controller.fromDateController.dispose();
  //   controller.toDateController.dispose();
  //   controller.locationController.dispose();
  //   controller.daysController.dispose();
  //   controller.perDiemController.dispose();
  //   controller.amountInController.dispose();
  //   controller.purposeController.dispose();
  //   super.dispose();
  // }

  void handleSubmit() {
    Navigator.pushNamed(context, AppRoutes.mileageExpense);
    print("Submit clicked");
  }

  void handleSave() {
    // Save logic here
    print("Save clicked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 1, 61), // Deep blue
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 1, 61),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Mileage Registration ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mileage Details ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    buildDateField(
                        "Receipt Date *", controller.fromDateController),
                    SearchableMultiColumnDropdownField<Project>(
                      labelText: 'Project Id *',
                      columnHeaders: const ['Project Name', 'Project Id'],
                      items: controller.project,
                      selectedValue: controller.selectedProject,
                      searchValue: (proj) => '${proj.name} ${proj.code}',
                      displayText: (proj) => proj.code,
                      validator: (proj) =>
                          proj == null ? 'Please select a Project' : null,
                      onChanged: (proj) {
                        setState(() {
                          controller.selectedProject = proj;
                          controller.selectedProject = proj;
                        });
                        controller.fetchExpenseCategory();
                      },
                      rowBuilder: (proj, searchQuery) {
                        Widget highlight(String text) {
                          final lowerQuery = searchQuery.toLowerCase();
                          final lowerText = text.toLowerCase();
                          final start = lowerText.indexOf(lowerQuery);
                          if (start == -1 || searchQuery.isEmpty)
                            return Text(text);

                          final end = start + searchQuery.length;
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: text.substring(0, start),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: text.substring(start, end),
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: text.substring(end),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(child: highlight(proj.name)),
                              Expanded(child: highlight(proj.code)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    SearchableMultiColumnDropdownField<Project>(
                      labelText: 'Mileage  *',
                      columnHeaders: const ['Mileage Name', 'Mileage Id'],
                      items: controller.project,
                      selectedValue: controller.selectedProject,
                      searchValue: (proj) => '${proj.name} ${proj.code}',
                      displayText: (proj) => proj.code,
                      validator: (proj) =>
                          proj == null ? 'Please select a Mileage' : null,
                      onChanged: (proj) {
                        setState(() {
                          controller.selectedProject = proj;
                          controller.selectedProject = proj;
                        });
                        controller.fetchExpenseCategory();
                      },
                      rowBuilder: (proj, searchQuery) {
                        Widget highlight(String text) {
                          final lowerQuery = searchQuery.toLowerCase();
                          final lowerText = text.toLowerCase();
                          final start = lowerText.indexOf(lowerQuery);
                          if (start == -1 || searchQuery.isEmpty)
                            return Text(text);

                          final end = start + searchQuery.length;
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: text.substring(0, start),
                                  style: const TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                  text: text.substring(start, end),
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: text.substring(end),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(child: highlight(proj.name)),
                              Expanded(child: highlight(proj.code)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    buildTextField("Vehicle *", controller.locationController),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientEnd,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Submit",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget buildDateField(String label, TextEditingController controller) {
    return buildTextField(
      label,
      controller,
      suffix: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            controller.text = picked.toString().split(' ')[0];
          }
        },
      ),
    );
  }

  Widget buildDropdownField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedProject.isEmpty ? null : selectedProject,
        onChanged: (value) {
          setState(() {
            selectedProject = value ?? '';
          });
        },
        items: projectList
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
