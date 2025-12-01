import 'package:digi_xpense/data/service.dart';
import 'package:flutter/material.dart';
import 'package:digi_xpense/data/models.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../l10n/app_localizations.dart';
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
      child: Scaffold(
        extendBody: true,
        body: HubMileageStepForm.buildStep(currentStep, widget.mileageId),
        bottomNavigationBar: BottomAppBar(
    color: Colors.transparent,        // remove background
  elevation: 0,                     // remove shadow
  surfaceTintColor: Colors.transparent,// 👈 For Material3 transparency
  child: Padding(
    padding: const EdgeInsets.all(0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // if (currentStep > 0)
        //   ElevatedButton(
        //     onPressed: _goToPreviousStep,
        //     child: Text(AppLocalizations.of(context)!.back),
        //   )
        // else
        //   const SizedBox(width: 80), // Placeholder for spacing

        if (currentStep < 1)
          ElevatedButton(
            onPressed: _goToNextStep,
            child: Text(AppLocalizations.of(context)!.next),
          ),
      ],
    ),
  ),
),

      ),
    );
  }
}
