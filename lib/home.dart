import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onclip/settings.dart';
import 'package:onclip/utils/api_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController clipboard = TextEditingController();
  final TextEditingController addConnectionTextField = TextEditingController();

  String clipboardData = "";
  List<String> connections = [];

  String savedEndpoint = "";
  String currentConnection = "Default";
  String connectionStatus = "Connecting";
  Color connectionIndicator = Colors.orangeAccent;

  @override
  void initState(){
    super.initState();
    getSavedConnections();
    getSavedEndpoint();
  }

  void openDrawer() {
    scaffoldKey.currentState!.openEndDrawer();
  }
  
  void closeDrawer(){
    scaffoldKey.currentState!.closeEndDrawer();
  }

  Future<void> getSavedEndpoint() async{
    final settings = await SharedPreferences.getInstance();
    savedEndpoint = settings.getString("endpoint") ?? '';
    
    getClipboardData(settings.getString("endpoint") ?? '', "Default");
  }

  void getClipboardData(String endpoint, String conn) async{
    setState((){
      currentConnection = conn;
      connectionStatus = "Connecting";
      connectionIndicator = Colors.orangeAccent;
    });

    try{
      clipboardData = await getClipboard(endpoint, conn);
      setState(() {
        connectionStatus = "Connected";
        connectionIndicator = Colors.green;
        clipboard.text = clipboardData;
      });
    }catch(error){
      setState(() {
        connectionStatus = "Disconnected";
        connectionIndicator = Colors.redAccent;
        clipboard.text = "";
      });
    }
  }

  void saveClipboardData(String endpoint, String conn, data) async{
    setState((){
      currentConnection = conn;
      connectionStatus = "Saving";
      connectionIndicator = Colors.orangeAccent;
    });

    try{
      clipboardData = await saveClipboard(endpoint, conn, data);
      setState(() {
        connectionStatus = "Saved";
        connectionIndicator = Colors.green;
      });

      Future.delayed(
        Duration(seconds: 3),
        (){
          setState(() {
            connectionStatus = "Connected";
          });
        },
      );
    }catch(error){
      setState(() {
        connectionStatus = "Saving Failed";
        connectionIndicator = Colors.redAccent;
      });

      Future.delayed(
        Duration(seconds: 3),
        (){
          setState(() {
            connectionStatus = "Connected";
            connectionIndicator = Colors.green;
          });
        },
      );
    }
  }

  void addConnection(String connectionString) async{
    final settings = await SharedPreferences.getInstance();
    List<String> cons = settings.getStringList("connections") ?? [];
    String trimmedCon = connectionString.length > 5 ? connectionString.substring(0, 5) : connectionString; 

    if(!cons.contains(connectionString)){
      cons.add(trimmedCon);
      setState(() {
        addConnectionTextField.text = "";
      });
    }

    settings.setStringList("connections", cons);

    getClipboardData(savedEndpoint, trimmedCon);
    getSavedConnections();
  }

  void deleteConnection(String connectionString) async{
    final settings = await SharedPreferences.getInstance();
    List<String> cons = settings.getStringList("connections") ?? [];

    if(cons.contains(connectionString)){
      cons.remove(connectionString);
    }

    settings.setStringList("connections", cons);
    getSavedConnections();
  }

  void getSavedConnections() async{
    final settings = await SharedPreferences.getInstance();
    
    setState(() {
      connections = settings.getStringList("connections") ?? ["Default"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 8.0,
          children: [
            InkWell(
              onTap: () {
                getClipboardData(savedEndpoint, currentConnection);
              },
              borderRadius: BorderRadius.circular(50),
              splashColor: Colors.yellowAccent,
              highlightColor: Colors.yellowAccent,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: connectionIndicator,
              ),
            ),
            Text(currentConnection, 
              style: TextStyle(
                fontSize: 16
              ),
            ),
            Text(connectionStatus, 
              style: TextStyle(
                fontSize: 12
              ),
            ),
          ],
        ),
        shape: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 2.0
          )
        ),
        actionsPadding: EdgeInsets.only(right: 8.0),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            color: Colors.black,
            iconSize: 24,
            onPressed: () async{
              await Clipboard.setData(
                ClipboardData(text: clipboard.text),
              );

              (){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Copied!"))
                );
              }();
            },
          ),
          IconButton(
            icon: Icon(Icons.paste),
            color: Colors.black,
            iconSize: 24,
            onPressed: () async{
              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

              if(data != null && data.text != null){
                String txt = data.text!;

                setState(() {
                  clipboard.text = txt;
                });
              }
              
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            color: Colors.black,
            iconSize: 24,
            onPressed: () => {
              if(clipboard.text.trim().isNotEmpty){
                saveClipboardData(savedEndpoint, currentConnection, clipboard.text.trim())
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.black,
            iconSize: 24,
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings()
                ),
              ),
            },
            onLongPress: () => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("404"))
              )
            },
          ),
        ],
      ),
      key: scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          key: PageStorageKey("clipboardWrapper"),
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width, maxWidth: 5000),
            child: TextField(
              controller: clipboard,
              key: ValueKey("clipboardData"),
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Start Typing...',
                contentPadding: EdgeInsets.all(8),
              ),
              autocorrect: false,
              onChanged: (value) => {
                clipboard.text = value
              },
            ),
          ),
        ),
      ),
      endDrawer: NavigationDrawer(
        header: Padding(
          padding: EdgeInsetsGeometry.all(8.0),
          child: Text("Select Connections"),
        ),
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: connections.map((con) => SizedBox(
                    width: MediaQuery.of(context).size.height,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: ElevatedButton(
                        onPressed: (){
                          getClipboardData(savedEndpoint, con);
                          closeDrawer();
                        },
                        onLongPress: () {
                          deleteConnection(con);
                        },
                        child: Text(con),
                      ),
                    ),
                  )).toList(),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: TextField(
                      controller: addConnectionTextField,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        contentPadding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                        constraints: BoxConstraints(
                          maxWidth: 5.0
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      onPressed: (){
                        if(addConnectionTextField.text.trim().isNotEmpty){
                          addConnection(addConnectionTextField.text);
                          closeDrawer();
                        }
                      },
                      child: Text(
                        "ADD",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDrawer();
        },
        tooltip: 'Select/Add Connection',
        backgroundColor: Colors.white,
        child: Icon(
          Icons.select_all
        ),
      ),
    );
  }
}
