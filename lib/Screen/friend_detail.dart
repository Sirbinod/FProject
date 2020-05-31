import 'package:demofriendlocator/Utils/friend_database.dart';
import 'package:flutter/material.dart';
import '../Model/friend.dart';
import 'package:intl/intl.dart';

class FriendDetail extends StatefulWidget {
  final String appBarTitle;
  final Friend friend;

  FriendDetail(this.friend, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return FriendDetailState(this.friend, this.appBarTitle);
  }
}

class FriendDetailState extends State<FriendDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Friend friend;

  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  FriendDetailState(this.friend, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    nameController.text = friend.name;
    numberController.text = friend.number;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: nameController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateName();
                    },
                    decoration: InputDecoration(
                        labelText: 'friend Name',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: numberController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateNumber();
                    },
                    decoration: InputDecoration(
                        labelText: 'Friend Number',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Update the title of todo object
  void updateName() {
    friend.name = nameController.text;
  }

  // Update the description of todo object
  void updateNumber() {
    friend.number = numberController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    friend.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (friend.id != null) {
      // Case 1: Update operation
      result = await helper.updateFriend(friend);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertFriend(friend);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Friend Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Friend');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (friend.id == null) {
      _showAlertDialog('Status', 'No friend list was deleted');
      return;
    }

    int result = await helper.deleteFriend(friend.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Todo Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Todo');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
