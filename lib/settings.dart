import 'package:flutter/material.dart';
import 'package:onclip/utils/api_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _Settings();
}
class _Settings extends State<Settings> {
  late Future futureData;
  TextEditingController textFieldEndpoint = TextEditingController();

  bool testEndpointBool = false;
  String savedEndpoint = "";

  @override
  void initState() {
    super.initState();
    getSavedEndpoint();
  }

  Future<void> saveSettings() async{
    final settings = await SharedPreferences.getInstance();
    settings.setString('endpoint', textFieldEndpoint.text);
  }

  Future<void> getSavedEndpoint() async{
    final settings = await SharedPreferences.getInstance();
    savedEndpoint = settings.getString('endpoint') ?? '';
  }

  @override
  void dispose(){
    textFieldEndpoint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(height: 12),
              TextField(
                controller: textFieldEndpoint,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Endpoint"
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                child: Text("TEST ENDPOINT"),
                onPressed: () {
                  setState(() {
                    testEndpointBool = true;
                    futureData = testEndpoint(textFieldEndpoint.text.trim().isEmpty ? savedEndpoint : textFieldEndpoint.text, "Default");
                  });
                },
              ),
              SizedBox(height: 6),
              if(testEndpointBool) (
                FutureBuilder(
                  future: futureData,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return Text(
                        snapshot.data!,
                        textAlign: TextAlign.center,
                      );
                    }else if(snapshot.hasError){
                      return Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      );
                    }

                    return const CircularProgressIndicator();
                  },
                )
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.only(bottom: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        icon: Icon(Icons.save),
                        label: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        onPressed: (){
                          print("S");
                          saveSettings();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Settings Saved"),
                              action: SnackBarAction(
                                label: "OK",
                                onPressed: (){}
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}