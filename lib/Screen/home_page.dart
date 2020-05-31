import 'package:flutter/material.dart';
import './friend_list.dart';
import './start_page.dart';
import 'package:geolocator/geolocator.dart';
import '../Screen/profile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  String _locationMessage = "";
  void _getCurrentLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
    setState(() {
      _locationMessage = "${position.latitude},${position.longitude}";
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.,
        appBar: AppBar(
          title: Text('Friend Locator'),
        ),
        body: Container(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Current Location :",
                style: TextStyle(letterSpacing: 2.0, fontSize: 15.0),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(_locationMessage),
              Divider(
                height: 40.0,
              ),
              Text(
                'Tap the button to send your location:',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                height: 20.0,
              ),
              RawMaterialButton(
                onPressed: () {
                  _getCurrentLocation();
                  _ackAlert(context);
                },
                child: new Icon(
                  Icons.warning,
                  color: Colors.redAccent,
                  size: 250.0,
                ),
                shape: new CircleBorder(),
                elevation: 6.0,
                fillColor: Colors.yellow,
                padding: const EdgeInsets.all(30.0),
              ),
              SizedBox(
                height: 40.0,
              ),
            ],
          ),
        )),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.library_add),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => FriendList()));
                },
              ),
              IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Profile()));
                },
              ),
              IconButton(
                icon: Icon(Icons.star),
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => StartPage()));
                },
              ),
            ],
          ),
        ));
  }
}

Future<void> _ackAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('SMS sent'),
        content: const Text('this SMS sent you friend'),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
