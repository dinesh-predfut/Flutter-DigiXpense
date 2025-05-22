import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:digi_xpense/data/pages/screen/widget/router/router.dart';

import '../../../service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
  final controller = Get.put(Controller());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Purple header
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF5B0DCD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: const Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 40,
                  left: 16,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Icon(Icons.notifications, color: Colors.white),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(10, -50),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: controller.imageFile != null
                      ? FileImage(controller.imageFile!)
                      : const AssetImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png')
                          as ImageProvider,
                ),
                GestureDetector(
                  onTap: controller.pickImage,
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 16),
                  ),
                ),
              ],
            ),
          ),

          // 3. Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                const Center(
                  child: Text('Rose',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text('rose@gmail.com | +01 234 567 89',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                _buildMenuItem("Personal Details",(){Navigator.pushNamed(context, AppRoutes.personalInfo);}),
                _buildMenuItem("Language Settings",(){ Navigator.pushNamed(context, AppRoutes.changesLanguage);}), 
                _buildMenuItem("App Settings",(){}),
                _buildMenuItem("Help & Support",(){}),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Log Out',
                        style: TextStyle(color: Colors.red)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _buildMenuItem(String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  );
}

}



