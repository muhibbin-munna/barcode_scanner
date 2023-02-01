import 'dart:convert';

import 'package:barcode_scanner/db/offline_database.dart';
import 'package:barcode_scanner/model/constants.dart';
import 'package:barcode_scanner/pages/config_page.dart';
import 'package:barcode_scanner/pages/manual_send.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scanner/model/note.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];

class NoteCardWidget extends StatelessWidget {
  NoteCardWidget(
      {Key? key,
      required this.note,
      required this.index,
      required this.notifyParent})
      : super(key: key);

  final Note note;
  final int index;

  final Function() notifyParent;

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index
    final color = _lightColors[index % _lightColors.length];
    final time = DateFormat('yyyy-MM-dd, hh:mm a').format(note.createdTime);
    final minHeight = getMinHeight(index);
    late List<String> keys = [];
    json.decode(note.details).forEach((key, value) {
      keys.add(key);
    });

    // Try to send data
    sendData() async {
      String current_output = note.details;
      print('current_output : ' + current_output);

      final encoded_current_output =
          base64.encode(utf8.encode(current_output)); //Base 64 Encoded
      print('encoded_unsent_output : ' + encoded_current_output);

      var ulrEncoded =
          Uri.encodeComponent(encoded_current_output); //Url Encoded
      print('ulrEncoded : ' + ulrEncoded);

      var CHECKSUM1 = sha256
          .convert(utf8.encode(ulrEncoded))
          .toString(); //SHA256 Encoded without KEY
      print('CHECKSUM1 : ' + CHECKSUM1);

      //Fetch Configuration Data from share preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String api_url = (prefs.getString(Constants.API_URL) ?? '');
      String devId = (prefs.getString(Constants.DEVICE_ID) ?? '');
      String key = (prefs.getString(Constants.KEY) ?? '');

      if (api_url.isEmpty || devId.isEmpty || key.isEmpty) {
        //if configuration is not set
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: 'Set configuration first',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Config()));
      } else {
        if (!api_url.contains('http')) {
          //add http if no http in the link
          api_url = 'https://' + api_url;
        }
        print('api_url' + api_url);

        var url = Uri.parse(api_url); //Parse uri from url

        var CHECKSUM2 = sha256
            .convert(utf8.encode(CHECKSUM1 + key))
            .toString(); //SHA256 Encoded with KEY
        print('CHECKSUM2 : ' + CHECKSUM2);

        try{
          var response = await http.post(url, body: {
            //send request to server with post request
            'data': encoded_current_output,
            'checksum': CHECKSUM2,
            'id': devId
          }).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              // Time has run out, do what you wanted to do.
              return Response('Error', 500);
            },
          );
          print('Status : ${response.statusCode}, Body : ${response.body}');

          if (response.body == 'OK') {
            Fluttertoast.showToast(
                msg: 'Status : ${response.statusCode}, Body : ${response.body}',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
            await OfflineDatabase.instance.delete(note
                .id!); //if data send OK then remove that product from database
            notifyParent(); //Refresh the page after removing database
            Navigator.of(context).pop();
          } else if (response.body == 'Error') {
            Fluttertoast.showToast(
                msg: 'Server Timeout, check the URL again',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
            Navigator.of(context).pop();
          }else if (response.statusCode == 301) {
            Fluttertoast.showToast(
                msg: 'Check the HTTP again',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
            Navigator.of(context).pop();
          } else {
            Fluttertoast.showToast(
                msg: 'Could not send data to the server',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
            Navigator.pop(context);
          }
        }catch(e){
          Fluttertoast.showToast(
              msg: 'No response from the server, check URL again',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          Navigator.of(context).pop();
        }

      }
    }

    Future<bool> getInternetUsingInternetConnectivity() async {
      //Check internet connection
      bool result = await InternetConnectionChecker().hasConnection;
      return result;
    }

    return Card(
      color: color,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              time,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            SizedBox(height: 4),
            Text(
              'DNN List : $keys',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
                child: Text("Try again", style: TextStyle(fontSize: 16)),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(5)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.red)))),
                onPressed: () async {
                  showLoaderDialog(context);
                  if (await getInternetUsingInternetConnectivity()) //Check internet connection
                  {
                    sendData();
                  } else {
                    Fluttertoast.showToast(
                        msg: 'You are offline, try again',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0);
                    Navigator.pop(context);
                  }
                  // await NotesDatabase.instance.delete(note.id!);
                  // notifyParent();
                }),
          ],
        ),
      ),
    );
  }

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 100;
      case 2:
        return 100;
      case 3:
        return 100;
      default:
        return 100;
    }
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
