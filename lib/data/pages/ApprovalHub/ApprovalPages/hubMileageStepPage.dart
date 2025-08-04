import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../screen/widget/router/router.dart';
import 'hubMileage/hubMileage_1.dart';
import 'hubMileage/hubMileage_2.dart';


class HubMileageStepForm extends StatefulWidget {
  final ExpenseModelMileage mileageId;

  const HubMileageStepForm({Key? key, required this.mileageId})
      : super(key: key);

  /// ✅ Static method to build any individual step globally
  static Widget buildStep(int step, ExpenseModelMileage mileageId) {
    switch (step) {
      case 0:
        return HubMileageFirstFrom(mileageId: mileageId);
      case 1:
        return HubMileageSecondFrom(mileageId: mileageId);
      default:
        return const Center(child: Text("Invalid Step"));
    }
  }

  @override
  State<HubMileageStepForm> createState() => _HubMileageStepFormState();
}

class _HubMileageStepFormState extends State<HubMileageStepForm> {
  int currentStep = 0;
  final controller = Get.put(Controller());

  void _goToNextStep() {
    if (currentStep < 1) {
      setState(() {
        currentStep++;
      });
    } else {
      // TODO: Handle submit action
    }
  }

  void _goToPreviousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   return WillPopScope(
      onWillPop: () async {
        controller.clearFormFields();
        controller.isEnable.value = false;
        controller.isLoadingGE1.value = false;
        Navigator.pushNamed(context, AppRoutes.approvalHubMain);
        return true;
      },
      child:  Scaffold(
  
      body: Column(
        children: [
          Expanded(
            child: HubMileageStepForm.buildStep(currentStep, widget.mileageId),
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [ 
                if (currentStep > 0)
                  ElevatedButton(
                    onPressed: _goToPreviousStep,
                    child: const Text("Back"),
                  ),
                  if(currentStep == 0 )
                  
                ElevatedButton(
                  onPressed: _goToNextStep,
                  child: Text( "Next"),
                ),
              ],
            ),
          ),
        ],
      ),
   ));
  }
}
