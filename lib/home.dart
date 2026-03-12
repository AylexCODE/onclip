import 'package:flutter/material.dart';
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

  String clipboardData = "";

  String savedEndpoint = "";
  String connectionStatus = "Connecting";
  Color connectionIndicator = Colors.orangeAccent;

  @override
  void initState(){
    super.initState();
    getSavedEndpoint();
  }

  void openDrawer() {
    scaffoldKey.currentState!.openEndDrawer();
  }

  Future<void> getSavedEndpoint() async{
    final settings = await SharedPreferences.getInstance();

    setState(() {
      savedEndpoint = settings.getString('endpoint') ?? '';
    });

    getClipboardData(settings.getString("endpoint") ?? '', "Default");
  }

  void getClipboardData(String endpoint, String conn) async{
    setState((){
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

  void setConnectionState(){
    
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
                getClipboardData(savedEndpoint, "Default");
              },
              borderRadius: BorderRadius.circular(50),
              splashColor: Colors.yellowAccent,
              highlightColor: Colors.yellowAccent,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: connectionIndicator,
              ),
            ),
            Text("Default", 
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
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings()
                ),
              ),
            },
          ),
          IconButton(
            icon: Icon(Icons.paste),
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
          ),
          IconButton(
            icon: Icon(Icons.save),
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
                SizedBox(
                  width: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: ElevatedButton(
                      onPressed: (){},
                      child: Text("data")
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(8.0, 8.0, 8.0, 0.0),
                    child: ElevatedButton(
                      onPressed: (){},
                      child: Text("data")
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
        tooltip: 'Add Connection',
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add
        ),
      ),
    );
  }
}
