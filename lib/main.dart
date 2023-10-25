import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'JYEoVbNSy9mlCIpLwDgCB0l8tcj2lCYW65Ycmei1';
  final keyClientKey = 'siAwacle0D2Oii4433PeE5ksskOQvxCasoVw0VbA';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  void saveTask() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task details cannot be empty!"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTaskToParse(titleController.text, contentController.text);
    setState(() {
      titleController.clear();
      contentController.clear();
    });
  }

  void clearContent() {
    setState(() {
      titleController.clear();
      contentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = new DateFormat('MMM dd,\nyyyy\nhh:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text("Cross Platform Assignment - Task App"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      focusNode: null,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      cursorColor: Colors.blueGrey,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blueGrey),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blueGrey),
                          ),
                          labelText: "Task Title",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      focusNode: null,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      cursorColor: Colors.blueGrey,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.sentences,
                      controller: contentController,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blueGrey),
                          ),
                          focusedBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.blueGrey),
                          ),
                          labelText: "Task Content",
                          labelStyle: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0.0),
              child: Row(children: <Widget>[
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      minimumSize: Size(142, 40),
                    ),
                    onPressed: clearContent,
                    child: Text("Clear")),
                SizedBox(width: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                      minimumSize: Size(242, 40),
                    ),
                    onPressed: saveTask,
                    child: Text("Save Task")),
              ])),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTodo(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blueGrey),
                              )),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTask = snapshot.data![index];
                                final varTitle = varTask.get<String>('title')!;
                                final varContent =
                                    varTask.get<String>('content')!;
                                final varStatus = varTask.get<bool>('status')!;
                                final varDate = dateFormat.format(
                                    varTask.get<DateTime>('updatedAt')!);
                                //*************************************

                                return ListTile(
                                  title: Text(varTitle),
                                  subtitle: Text(varContent),
                                  isThreeLine: true,
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4.0),
                                          bottomRight: Radius.circular(4.0),
                                          topLeft: Radius.circular(4.0),
                                          bottomLeft: Radius.circular(4.0)),
                                    ),
                                    padding:
                                        EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                                    // color: Colors.grey,
                                    child: Text(
                                      varDate,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        // fontWeight: YourFontWeight
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varStatus,
                                          activeColor: Colors.blueGrey,
                                          onChanged: (value) async {
                                            await updateTodo(
                                                varTask.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.blueGrey,
                                        ),
                                        onPressed: () async {
                                          await deleteTodo(varTask.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text(
                                                  "Task Deleted Successfully!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  Future<void> saveTaskToParse(String title, String content) async {
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('content', content)
      ..set('status', false);
    await task.save();
  }

  Future<List<ParseObject>> getTodo() async {
    QueryBuilder<ParseObject> queryTask =
        QueryBuilder<ParseObject>(ParseObject('Task'));
    final ParseResponse apiResponse = await queryTask.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTodo(String id, bool status) async {
    var task = ParseObject('Task')
      ..objectId = id
      ..set('status', status);
    await task.save();
  }

  Future<void> deleteTodo(String id) async {
    var task = ParseObject('Task')..objectId = id;
    await task.delete();
  }
}
