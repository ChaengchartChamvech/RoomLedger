import 'dart:typed_data';

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

  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    addressController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();

    setState(() {
      selectedImage = xfile;
      selectedImageBytes = bytes;
    });
  }

  Future<String> uploadRoomImage(XFile file) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final fileName = "${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext";

    await supabase.storage.from('images').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(upsert: false),
    );

    return supabase.storage.from('images').getPublicUrl(fileName);
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
    debugPrint('Current user id: ${user.id}');
    if (title.isEmpty) {
      showError("Please enter room title");
      return;
    }

    if (price == null || price <= 0) {
      showError("Please enter valid price");
      return;
    }

    if (selectedImage == null) {
      showError("Please pick a room image");
      return;
    }

    try {
      setState(() => isSaving = true);

      final imageUrl = await uploadRoomImage(selectedImage!);

      await supabase.from('rooms').insert({
        'owner_id': user.id,
        'name': title,
        'description': desc.isEmpty ? null : desc,
        'location': address.isEmpty ? null : address,
        'price_per_night': price,
        'image_url': imageUrl,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } on StorageException catch (e) {
      showError("Upload error: ${e.message}");
    } on PostgrestException catch (e) {
      showError("Database error: ${e.message}");
    } catch (e) {
      showError("Error: $e");
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
                ),
                clipBehavior: Clip.antiAlias,
                child: selectedImageBytes != null
                    ? Image.memory(
                        selectedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 34),
                          SizedBox(height: 8),
                          Text(
                            "Tap to add room image",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
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

            _Input(
              label: "Price / Night (Start)",
              controller: priceController,
              hint: "15000",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveRoom
                  ,
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}