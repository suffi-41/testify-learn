import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const cloudName = 'dbvotow1k'; // replace with your Cloudinary cloud name
  const uploadPreset = 'testify_learn'; // replace with your upload preset

  final uri = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  var request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = uploadPreset
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
