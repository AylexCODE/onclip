import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getClipboard(String endpoint, String conn) async{
  final response = await http.get(
    Uri.parse("$endpoint$conn"),
    headers: {
      HttpHeaders.contentTypeHeader: 'text/plain'
    }
  );
  
  if(response.statusCode == 200){
    return response.body;
  }else{
    throw Exception("Error ${response.statusCode}");
  }
}

Future saveClipboard(String endpoint, String conn) async{
  final response = await http.get(
    Uri.parse("$endpoint$conn"),
    headers: {
      HttpHeaders.contentTypeHeader: 'text/plain'
    }
  );
  
  if(response.statusCode == 200){
    return response.body;
  }else{
    throw Exception("Error ${response.statusCode}");
  }
}

Future testEndpoint(String endpoint, String conn) async{
  final response = await http.get(
    Uri.parse("$endpoint$conn"),
    headers: {
      HttpHeaders.contentTypeHeader: 'text/plain'
    }
  );
  
  if(response.statusCode == 200){
    return "ok";
  }else{
    throw Exception("Error ${response.statusCode}");
  }
}