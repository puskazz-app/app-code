import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GitHubApi {
  final String uniqueId;

  GitHubApi({required this.uniqueId});

  Future<void> uploadMarkdownFile(String filePath) async {
    try {
      // Read the contents of the Markdown file
      File file = File(filePath);
      String content = await file.readAsString();

      // Create a unique file name for the GitHub upload
      String fileName = 'cheat.md';
      String dateFormat =
          DateFormat("yyyyMMddHHmm").format(DateTime.now()) + '_' + uniqueId;
      // Set the file path on GitHub
      String githubFilePath = '$dateFormat/$fileName';
      await dotenv.load(fileName: ".env");

      // Use the GitHub API to upload the file
      final url = Uri.https(
        'api.github.com',
        'repos/${dotenv.env['GH_USERNAME'] ?? ''}/${dotenv.env['GH_REPO_NAME'] ?? ''}/contents/$githubFilePath',
      );

      var token = dotenv.env['GITHUB_API_KEY'] ?? '';

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Upload Markdown file',
          'content': base64Encode(utf8.encode(content)),
        }),
      );

      if (response.statusCode == 201) {
        print('Markdown file uploaded successfully.');
      } else {
        print(
            'Failed to upload Markdown file. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> uploadPngFile(String filePath, int index) async {
    try {
      // Read the contents of the PNG file
      File file = File(filePath);
      List<int> bytes = await file.readAsBytes();

      // Convert to base64
      String base64String = base64Encode(bytes);

      // Create a unique file name for the GitHub upload
      String fileName = 'image_${index}.png';
      String dateFormat =
          DateFormat("yyyyMMddHHmm").format(DateTime.now()) + '_' + uniqueId;
      // Set the file path on GitHub
      String githubFilePath = '$dateFormat/$fileName';

      await dotenv.load(fileName: ".env");

      // Use the GitHub API to upload the file
      final url = Uri.https(
        'api.github.com',
        'repos/${dotenv.env['GH_USERNAME'] ?? ''}/${dotenv.env['GH_REPO_NAME'] ?? ''}/contents/$githubFilePath',
      );

      var token = dotenv.env['GITHUB_API_KEY'] ?? '';

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Upload PNG file',
          'content': base64String,
        }),
      );

      if (response.statusCode == 201) {
        print('PNG file uploaded successfully.');
      } else {
        print('Failed to upload PNG file. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
