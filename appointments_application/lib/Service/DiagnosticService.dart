import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class DiagnosticService {
  final String baseUrl;
  DiagnosticService(this.baseUrl);

  Future<Map<String, dynamic>> sendDiagnostic({
    File? photo,
    required String description,
    required int agenceId,
  }) async {

    final url = '$baseUrl/api/diagnostic/analyze';

    print(url);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.fields['Description'] = description;

    if (photo != null) {
      final mimeType = lookupMimeType(photo.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'Photo',
          photo.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );
    }

    print("Envoi...");

    final response = await request.send();

    print(response.statusCode);

    final body = await response.stream.bytesToString();

    print(body);

    return jsonDecode(body);
  }
}
