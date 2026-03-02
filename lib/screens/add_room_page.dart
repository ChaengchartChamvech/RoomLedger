import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final addressController = TextEditingController();
  final priceController = TextEditingController();
  final bedController = TextEditingController(text: "0");
  final bathController = TextEditingController(text: "0");

  File? selectedImage;
  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    addressController.dispose();
    priceController.dispose();
    bedController.dispose();
    bathController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xfile == null) return;

    setState(() {
      selectedImage = File(xfile.path);
    });
  }

  Future<String> uploadRoomImage(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    // Make unique filename
    final ext = file.path.split('.').last.toLowerCase();
    final fileName =
        "${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext";

    // Upload
    await supabase.storage.from('images').upload(fileName, file);

    // Get public URL
    final url = supabase.storage.from('images').getPublicUrl(fileName);
    return url;
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> saveRoom() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      showError("Please login again.");
      return;
    }

    final title = titleController.text.trim();
    final desc = descController.text.trim();
    final address = addressController.text.trim();
    final price = int.tryParse(priceController.text.trim());
    final beds = int.tryParse(bedController.text.trim()) ?? 0;
    final baths = int.tryParse(bathController.text.trim()) ?? 0;

    if (title.isEmpty) return showError("Please enter room title");
    if (price == null || price <= 0) return showError("Please enter valid price");
    if (selectedImage == null) return showError("Please pick a room image");

    try {
      setState(() => isSaving = true);

      // 1) Upload image to storage
      final imageUrl = await uploadRoomImage(selectedImage!);

      // 2) Insert room
      await supabase.from('rooms').insert({
        'owner_id': user.id,
        'title': title,
        'description': desc.isEmpty ? null : desc,
        'address': address.isEmpty ? null : address,
        'price_per_month': price,
        'bedrooms': beds,
        'bathrooms': baths,
        'image_url': imageUrl,
        'is_available': true,
      });

      if (!mounted) return;
      Navigator.pop(context, true); // return success
    } on StorageException catch (e) {
      showError("Upload error: ${e.message}");
    } on PostgrestException catch (e) {
      showError("Database error: ${e.message}");
    } catch (e) {
      showError("Error: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Room"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image picker
            InkWell(
              onTap: isSaving ? null : pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x22000000)),
                  image: selectedImage != null
                      ? DecorationImage(
                          image: FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: selectedImage == null
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 34),
                          SizedBox(height: 8),
                          Text("Tap to add room image",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 14),

            _Input(
              label: "Title",
              controller: titleController,
              hint: "e.g. Cozy Studio near BTS",
            ),
            const SizedBox(height: 12),

            _Input(
              label: "Description",
              controller: descController,
              hint: "e.g. Fully furnished, quiet, good location",
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            _Input(
              label: "Address",
              controller: addressController,
              hint: "e.g. Sukhumvit, Bangkok",
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _Input(
                    label: "Price / month",
                    controller: priceController,
                    hint: "15000",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Input(
                    label: "Bedrooms",
                    controller: bedController,
                    hint: "0",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _Input(
                    label: "Bathrooms",
                    controller: bathController,
                    hint: "0",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(), // keep layout balanced
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveRoom,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Room",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Input({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}