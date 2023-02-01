//This page contains if to scan more ean or send data

import 'dart:convert';
import 'package:barcode_scanner/db/offline_database.dart';
import 'package:barcode_scanner/model/note.dart';
import 'package:barcode_scanner/pages/config_page.dart';
import 'package:barcode_scanner/pages/home_screen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import 'package:barcode_scanner/model/constants.dart';
import 'package:barcode_scanner/pages/dnn_scan.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final _formKey = GlobalKey<FormState>();
  late bool isSent;
  late String details;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Center(child: Text("Barcode Scanner")),
          backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                    child:
                        const Text("Next DNN", style: TextStyle(fontSize: 20)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)))),
                    onPressed: () {
                      //Navigate to DNN Page
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 4;
                      });
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DNNScan()));
                    }),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                    child: Text("Finished", style: TextStyle(fontSize: 20)),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)))),
                    onPressed: () {
                      showLoaderDialog(context);
                      sendData();
                    }),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                    child: Text("Home", style: TextStyle(fontSize: 20)),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.red)))),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (c) => HomeScreen()),
                          (route) => false);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Check Internet Connection
  Future<bool> getInternetUsingInternetConnectivity() async {
    bool result = await InternetConnectionChecker().hasConnection;
    return result;
  }

  // send data to server
  sendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String current_output = (prefs.getString(Constants.CURRENT_OUTPUT) ?? '');
    // String current_output = ('{"DNN00001":{"EAN0001":["10001","10002"],"EAN0002":["20001","20002","20003"],"EAN0003":["30001"]},"DNN00002":{"EAN0001":["X0001","X0002"]}}') ;

    final encoded_current_output = base64.encode(utf8.encode(current_output)); //Base 64 Encoded
    print('encoded_current_output : ' + encoded_current_output);

    var ulrEncoded = Uri.encodeComponent(encoded_current_output); //Url Encoded
    print('ulrEncoded : ' + ulrEncoded);

    var CHECKSUM1 = sha256.convert(utf8.encode(ulrEncoded)).toString(); //SHA256 Encoded without KEY
    print('CHECKSUM1 : ' + CHECKSUM1);

    //Fetch Configuration Data from share preference
    String api_url = (prefs.getString(Constants.API_URL) ?? '');
    String devId = (prefs.getString(Constants.DEVICE_ID) ?? '');
    String key = (prefs.getString(Constants.KEY) ?? '');

    if (api_url.isEmpty || devId.isEmpty || key.isEmpty) {  //if configuration is not set
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: 'Set configuration first',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Config()));
    }
    else if (!await getInternetUsingInternetConnectivity()) { //Check internet connection
      //If no internet save data to offline and go back to home page
      await addNote(current_output);
      Fluttertoast.showToast(
          msg: 'You are offline, saved to offline',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => HomeScreen()), (route) => false);
    } else {
      if (!api_url.contains('http')) { //add http if no http in the link
        api_url = 'https://' + api_url;
      }
      print('api_url' + api_url);

      var url = Uri.parse(api_url); //Parse uri from url

      var CHECKSUM2 = sha256.convert(utf8.encode(CHECKSUM1 + key)).toString(); //SHA256 Encoded with KEY
      print('CHECKSUM2 : ' + CHECKSUM2);

      try{
        var response = await http.post(url, body: { //send request to server with post request
          'data': encoded_current_output,
          'checksum': CHECKSUM2,
          'id': devId
        }).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            return http.Response('Error', 500);
          },
        );

        if (response.body == 'OK') {
          Fluttertoast.showToast(
              msg: 'Status : ${response.statusCode}, Body : ${response.body}',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          Navigator.pop(context);

        } else if (response.body == 'Error'){
          await addNote(current_output);
          Fluttertoast.showToast(
              msg: 'Server Timeout, check the URL again',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          Navigator.of(context).pop();
        }else if (response.statusCode == 301) {
          await addNote(current_output);
          Fluttertoast.showToast(
              msg: 'Check the HTTP again',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          Navigator.of(context).pop();
        } else {
          //Add note to database if response is not OK
          await addNote(current_output);
          Fluttertoast.showToast(
              msg: 'Could not send data to the server',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          Navigator.of(context).pop();
        }
      }catch(e){
        await addNote(current_output);
        Fluttertoast.showToast(
            msg: 'No response from the server, check URL again',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        Navigator.pop(context);

      }

    }
  }

  Future addNote(String current_output) async {
    final note = Note(
      details: current_output,
      createdTime: DateTime.now(), //Save time to database
      isSent: true,
    );

    await OfflineDatabase.instance.create(note); //add data to database
  }

  //Alert dialog while loading
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Please wait...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
