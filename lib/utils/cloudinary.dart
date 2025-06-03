import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(
  File imageFile, {
  String folderName = "testify_learn/imagesR", // Default base folder
}) async {
  const cloudName = 'dbvotow1k';
  const uploadPreset = 'testify_learn';

  // Clean folder path: Remove leading/trailing slashes
  final cleanFolder = folderName.replaceAll(RegExp(r'^/|/$'), '');

  final uri = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  var request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset
    ..fields['folder'] =
        cleanFolder // Use cleaned path
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);
    return jsonResponse['secure_url'];
  } else {
    print('Cloudinary upload failed: ${response.statusCode}');
    return null;
  }
}
