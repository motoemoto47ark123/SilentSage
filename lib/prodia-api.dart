import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cronet_http/cronet_http.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ProdiaAPI {
  static const String _apiKey = "bb7ea817-c286-4458-9a17-1d12824e0be9";
  static const String _apiEndpoint = "https://api.prodia.com/v1/sd/generate";
  static const String _jobStatusEndpoint = "https://api.prodia.com/v1/job/";

  static Future<Map<String, dynamic>> generateImage(String prompt) async {
    final Map<String, dynamic> requestData = {
      "model": "v1-5-pruned-emaonly.safetensors [d7049739]",
      "prompt": prompt,
      "negative_prompt": "",
      "steps": 20,
      "cfg_scale": 7.0, // Ensuring cfg_scale is a double to match expected 'num' type
      "seed": -1,
      "upscale": false,
      "sampler": "DPM++ 2M Karras",
      "width": 512,
      "height": 512,
    };

    final http.Client httpClient;
    final engine = CronetEngine.build(
      cacheMode: CacheMode.memory,
      cacheMaxSize: 2 * 1024 * 1024,
      userAgent: 'ProdiaAgent',
    );
    httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);

    try {
      final http.Response response = await httpClient.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Prodia-Key': _apiKey,
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final String jobId = jsonDecode(response.body)["job"];
        return await _pollJobStatus(httpClient, jobId);
      } else {
        return {"error": "Received a non-successful status code: ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Error: $e"};
    } finally {
      httpClient.close();
    }
  }

  static Future<Map<String, dynamic>> _pollJobStatus(http.Client httpClient, String jobId) async {
    const duration = Duration(seconds: 5);
    while (true) {
      final http.Response statusResponse = await httpClient.get(
        Uri.parse(_jobStatusEndpoint + jobId),
        headers: {
          'Content-Type': 'application/json',
          'X-Prodia-Key': _apiKey,
        },
      );

      if (statusResponse.statusCode == 200) {
        final Map<String, dynamic> statusData = jsonDecode(statusResponse.body);
        if (statusData["status"] == "succeeded") {
          final String imageUrl = statusData["imageUrl"];
          final http.Response imageResponse = await httpClient.get(Uri.parse(imageUrl));
          final String fileName = path.basename(imageUrl);
          final int fileSize = imageResponse.bodyBytes.length;
          // Ensuring fileSize is returned as an int to match expected 'int' type
          // Converting imageUrl to an int representation for the ID, which is a workaround for the main.dart requirement
          final int imageId = DateTime.now().millisecondsSinceEpoch; // Using current timestamp as a unique ID
          return {
            "imageId": imageId, // Providing an int ID instead of a String
            "imageUrl": imageUrl,
            "fileName": fileName,
            "fileSize": fileSize,
          };
        } else if (statusData["status"] == "failed") {
          return {"error": "Job failed"};
        }
        // If job is not succeeded or failed, wait and poll again
        await Future.delayed(duration);
      } else {
        return {"error": "Failed to get job status, status code: ${statusResponse.statusCode}"};
      }
    }
  }
}
