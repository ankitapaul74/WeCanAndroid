import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class CloudinaryImageService with ChangeNotifier {
  bool _isUploading = false;
  bool _isLoading = false;

  bool get isUploading => _isUploading;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dtnbn7tgs/image/upload";
  final String cloudinaryPreset = "our_leaders";
  final String apiKey = "335512955713285";
  final String apiSecret = "QyoDBTygS5qxiEsRfmmxJy_5odI";
  final String cloudName = "dtnbn7tgs";

  List<Map<String, dynamic>> _imageUrls = [];

  List<Map<String, dynamic>> get imageUrls => _imageUrls;

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      debugPrint('No image selected');
      return;
    }

    _isUploading = true;
    notifyListeners();

    try {
      File file = File(image.path);
      final imageBytes = await file.readAsBytes();

      final uploadResult = await uploadToCloudinary(imageBytes);

      if (uploadResult != null) {
        final imageUrl = uploadResult['secure_url'];
        final publicId = uploadResult['public_id'];

        if (imageUrl != null && publicId != null) {

          await _firestore.collection('images').add({
            'image_url': imageUrl,
            'public_id': publicId,
            'uploaded_at': Timestamp.now(),
          });

          await fetchImages();
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


  Future<Map<String, dynamic>?> uploadToCloudinary(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = cloudinaryPreset;
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        debugPrint('Error uploading image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error during Cloudinary upload: $e');
      return null;
    }
  }


  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final QuerySnapshot snapshot = await _firestore.collection('images').get();
      _imageUrls = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'image_url': data['image_url'] ?? '',
          'public_id': data['public_id'] ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> deleteImage(String imageId) async {
    try {
      final doc = await _firestore.collection('images').doc(imageId).get();
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('public_id')) {
        final publicId = data['public_id'] as String;

        final isDeletedFromCloudinary = await deleteFromCloudinary(publicId);

        if (isDeletedFromCloudinary) {

          await _firestore.collection('images').doc(imageId).delete();
          _imageUrls.removeWhere((image) => image['id'] == imageId);
          notifyListeners();
        } else {
          debugPrint('Failed to delete image from Cloudinary');
        }
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  Future<bool> deleteFromCloudinary(String publicId) async {
    final String url = "https://api.cloudinary.com/v1_1/$cloudName/image/destroy";


    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;


    final String signature = sha1.convert(utf8.encode("public_id=$publicId&timestamp=$timestamp$apiSecret")).toString();

    final Map<String, String> body = {
      "public_id": publicId,
      "api_key": apiKey,
      "timestamp": timestamp.toString(),
      "signature": signature,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['result'] == 'ok';
      } else {
        debugPrint('Error deleting image from Cloudinary: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during Cloudinary delete: $e');
      return false;
    }
  }
}
