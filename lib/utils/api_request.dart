import 'dart:io';

import 'package:http/http.dart' as http;

Future testEndpoint(String endpoint) async{
  final response = await http.get(
    Uri.parse(endpoint),
    headers: {
      HttpHeaders.contentTypeHeader: 'text/plain'
    }
  );
  
  if(response.statusCode == 200){
    return response.body;
  }else{
    return "Error ${response.statusCode}";
  }
}