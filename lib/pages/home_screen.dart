//Home page

import 'dart:async';
import 'dart:math';

import 'package:barcode_scanner/db/offline_database.dart';
import 'package:barcode_scanner/model/constants.dart';
import 'package:barcode_scanner/model/note.dart';
import 'package:barcode_scanner/pages/config_page.dart';
import 'package:barcode_scanner/pages/dnn_scan.dart';
import 'package:barcode_scanner/pages/manual_send.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int len = 0; //length of the offline data

  @override
  void initState() {
    super.initState();
    setSharedValue();  //init or reset shared preference value
    getDatabaseValue(); //Get database value of offline saved data
  }

  @override
  Widget build(BuildContext context) {
    getDatabaseValue(); //Recheck to show the manually send button
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(
                      height: 80,
                    ),
                    Container(
                      height: 150,
                      alignment: Alignment.center, // This is needed
                      child: Image.asset(
                        'assets/scanner.png',
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                    ),
                    Text(
                      "Barcode Scanner",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    if (len > 0)  //if saved database has more that 0 instance mean have data
                      TextButton(
                          child: Text("Send Manually",
                              style: TextStyle(fontSize: 20)),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(15)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.red)))),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ManualSend()));
                          }),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        child: const Text("New Scan",
                            style: TextStyle(fontSize: 20)),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.all(15)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)))),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DNNScan()));
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                    TextButton(
                        child: const Text("Configuration",
                            style: TextStyle(fontSize: 20)),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.all(15)),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)))),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Config()));
                        })
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  //init or reset shared preference value
  Future<void> setSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.DATA_EAN, '');
    await prefs.setString(Constants.CURRENT_DNN, '');
    await prefs.setString(Constants.CURRENT_OUTPUT, '');
  }

  //Get database value of offline saved data
  Future<void> getDatabaseValue() async {
    List<Note> notes = await OfflineDatabase.instance.readAllNotes();
    if (mounted) {
      setState(() {
        len = notes.length;
      });
    }

  }
}
