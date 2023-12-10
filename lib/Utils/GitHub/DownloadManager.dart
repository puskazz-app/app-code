import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GitHubImageDownloader {
  final String username;
  final String repository;
  final String branch;
  final String path;

  GitHubImageDownloader({
    required this.username,
    required this.repository,
    required this.branch,
    required this.path,
  });

  Future<String> downloadMarkdownFile() async {
    final apiUrl = Uri.https(
      'api.github.com',
      'repos/$username/$repository/contents/$path',
      {'ref': branch},
    );

    await dotenv.load(fileName: ".env");
    var token = dotenv.env['GITHUB_API_KEY'] ?? '';

    final response = await http.get(
      apiUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final downloadUrl = jsonResponse['download_url'];

      if (downloadUrl != null) {
        try {
          final markdownResponse = await http.get(
            Uri.parse(downloadUrl),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );

          if (markdownResponse.statusCode == 200) {
            // Convert the response body to a string
            String markdown = markdownResponse.body;

            debugPrint('Markdown: $markdown');

            return markdown;
          } else {
            throw Exception(
                'Failed to load Markdown. Status code: ${markdownResponse.statusCode}');
          }
        } catch (e) {
          print('Error downloading Markdown: $e');
          return '';
        }
      } else {
        print('Download URL not found in GitHub API response.');
        return '';
      }
    } else {
      print(
          'Failed to get repository contents. Status code: ${response.statusCode}');
      return '';
    }
  }

  Future<List<int>> downloadImage() async {
    final apiUrl = Uri.https(
      'api.github.com',
      'repos/$username/$repository/contents/$path',
      {'ref': branch},
    );

    await dotenv.load(fileName: ".env");
    var token = dotenv.env['GITHUB_API_KEY'] ?? '';

    final response = await http.get(
      apiUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final downloadUrl = jsonResponse['download_url'];

      if (downloadUrl != null) {
        try {
          final imageResponse = await http.get(
            Uri.parse(downloadUrl),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );

          if (imageResponse.statusCode == 200) {
            // Convert the response body to bytes
            Uint8List bytes = Uint8List.fromList(imageResponse.bodyBytes);

            debugPrint('Image bytes: $bytes');

            return bytes;
          } else {
            throw Exception(
                'Failed to load image. Status code: ${imageResponse.statusCode}');
          }
        } catch (e) {
          print('Error downloading image: $e');
          return [];
        }
      } else {
        print('Download URL not found in GitHub API response.');
        return [];
      }
    } else {
      print(
          'Failed to get repository contents. Status code: ${response.statusCode}');
      return [];
    }
  }
}
