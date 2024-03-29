import 'dart:convert'; // Importing Dart's built-in library for converting data between different formats (e.g., JSON).
import 'dart:async'; // Importing Dart's library for asynchronous programming, enabling concurrent operations.
import 'dart:io'; // Importing Dart's library for File, HTTP, and other I/O operations for Dart applications.
import 'package:cronet_http/cronet_http.dart'; // Importing the cronet_http package for making HTTP requests.
import 'package:http/http.dart' as http; // Importing the http package with a namespace 'http' to avoid naming conflicts.
import 'package:path/path.dart' as path; // Importing the path package with a namespace 'path' for path operations.
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';

// Defining the ProdiaAPI class to encapsulate all API-related operations for the Prodia service.
class ProdiaAPI {
  // Defining private static constants for API key and endpoints to ensure they are not modified elsewhere in the code.
  static const String _apiKey = "replace this with your api key";
  static const String _apiEndpoint = "https://api.prodia.com/v1/sd/generate";
  static const String _jobStatusEndpoint = "https://api.prodia.com/v1/job/";

  // Declaring a static asynchronous method to generate an image based on a given prompt.
  static Future<Map<String, dynamic>> generateImage(String prompt, Store<AppState> store) async {
    // Initializing a request data map with parameters required by the Prodia API for image generation.
    final Map<String, dynamic> requestData = {
      "model": "v1-5-pruned-emaonly.safetensors [d7049739]",
      "prompt": prompt,
      "negative_prompt": "",
      "steps": 20,
      "cfg_scale": 7.0, // Ensuring cfg_scale is a double to match expected 'num' type.
      "seed": -1,
      "upscale": false,
      "sampler": "DPM++ 2M Karras",
      "width": 512,
      "height": 512,
    };

    // Initializing an HTTP client using the Cronet engine for efficient network operations.
    final http.Client httpClient;
    final engine = CronetEngine.build(
      cacheMode: CacheMode.memory, // Setting cache mode to memory for faster access.
      cacheMaxSize: 2 * 1024 * 1024, // Setting maximum cache size to 2MB.
      userAgent: 'ProdiaAgent', // Custom user agent for identifying requests from this client.
    );
    httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true); // Creating the client and ensuring the engine is closed when done.

    try {
      // Making a POST request to the Prodia API endpoint with the request data and handling the response.
      final http.Response response = await httpClient.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json', // Specifying content type as JSON.
          'X-Prodia-Key': _apiKey, // Including the API key in the request headers for authentication.
        },
        body: jsonEncode(requestData), // Encoding the request data as a JSON string.
      );

      // Checking if the response status code is 200 (OK) to proceed with processing.
      if (response.statusCode == 200) {
        // Extracting the job ID from the response body to poll for the job status.
        final String jobId = jsonDecode(response.body)["job"];
        // Calling a helper method to poll the job status and return the result.
        return await _pollJobStatus(httpClient, jobId, store);
      } else {
        // Returning an error map if the response status code is not 200.
        return {"error": "Received a non-successful status code: ${response.statusCode}"};
      }
    } catch (e) {
      // Catching any exceptions during the request and returning an error map.
      return {"error": "Error: $e"};
    } finally {
      // Ensuring the HTTP client is closed to free up resources.
      httpClient.close();
    }
  }

  // Declaring a private static asynchronous method to poll the job status until completion.
  static Future<Map<String, dynamic>> _pollJobStatus(http.Client httpClient, String jobId, Store<AppState> store) async {
    // Defining a constant duration to wait between polling attempts.
    const duration = Duration(seconds: 5);
    // Entering a loop to continuously poll the job status.
    while (true) {
      // Making a GET request to the job status endpoint and handling the response.
      final http.Response statusResponse = await httpClient.get(
        Uri.parse(_jobStatusEndpoint + jobId), // Constructing the full endpoint URL with the job ID.
        headers: {
          'Content-Type': 'application/json', // Specifying content type as JSON.
          'X-Prodia-Key': _apiKey, // Including the API key in the request headers for authentication.
        },
      );

      // Checking if the response status code is 200 (OK) to proceed with processing.
      if (statusResponse.statusCode == 200) {
        // Decoding the response body to a Map for easier access to its properties.
        final Map<String, dynamic> statusData = jsonDecode(statusResponse.body);
        // Checking if the job status is "succeeded" to process the result.
        if (statusData["status"] == "succeeded") {
          // Extracting the image URL from the status data.
          final String imageUrl = statusData["imageUrl"];
          // Making a GET request to retrieve the image data.
          final http.Response imageResponse = await httpClient.get(Uri.parse(imageUrl));
          // Extracting the file name from the image URL using the path package.
          final String fileName = path.basename(imageUrl);
          // Calculating the file size from the response body bytes.
          final int fileSize = imageResponse.bodyBytes.length;
          // Generating a unique image ID using the current timestamp as a workaround.
          final int imageId = DateTime.now().millisecondsSinceEpoch;
          // Dispatching an action to update the Redux store with the new image details.
          store.dispatch(UpdateImageDetailsAction(imageId, imageUrl, fileName, fileSize));
          // Returning a map with the image details.
          return {
            "imageId": imageId, // Providing an int ID instead of a String.
            "imageUrl": imageUrl,
            "fileName": fileName,
            "fileSize": fileSize,
          };
        } else if (statusData["status"] == "failed") {
          // Returning an error map if the job status is "failed".
          return {"error": "Job failed"};
        }
        // If the job is neither succeeded nor failed, waiting for the specified duration before polling again.
        await Future.delayed(duration);
      } else {
        // Returning an error map if the response status code is not 200.
        return {"error": "Failed to get job status, status code: ${statusResponse.statusCode}"};
      }
    }
  }
}
