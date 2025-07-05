// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// Future<String> formatTextWithGemini(String rawText) async {
//   final String _apiKey = 'AIzaSyDyf1uHvNWnWIOQRnlXVHg9xBanWTlTdBg';
//   final url = Uri.parse(
//     "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$_apiKey",
//   );
//
//   final response = await http.post(
//     url,
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "contents": [
//         {
//           "parts": [
//             {
//               "text":
//                   "Please structure the following PDF text properly with clear headings, bullet points, and paragraphs:\n\n$rawText",
//             },
//           ],
//         },
//       ],
//     }),
//   );
//
//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['candidates'][0]['content']['parts'][0]['text'];
//   } else {
//     throw Exception("Gemini formatting failed: ${response.body}");
//   }
// }
