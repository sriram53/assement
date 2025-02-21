import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = "dpuvpthft";
  final String apiKey = "321565713467242";
  final String apiSecret = "iSSfTq30uBSEvpjhbGUcny0SYeQ";
  final String uploadPreset = "sriram"; // Replace with your actual upload preset

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonData = json.decode(responseData);

    if (response.statusCode == 200) {
      return jsonData["secure_url"];
    } else {
      print("Upload failed: ${jsonData['error']['message']}");
      return null;
    }
  }
}
