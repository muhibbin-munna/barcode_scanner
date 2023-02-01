//SNN Scan page

import 'dart:io';
import 'package:barcode_scanner/model/constants.dart';
import 'package:barcode_scanner/pages/ean_scan.dart';
import 'package:barcode_scanner/pages/next_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SNNScan extends StatefulWidget {
  String dnnCode, eanCode;

  SNNScan(this.dnnCode, this.eanCode, {Key? key}) : super(key: key);

  @override
  _SNNScanState createState() => _SNNScanState();
}

List<String> snnList = []; //List of SNN

class _SNNScanState extends State<SNNScan> {
  //init scanning
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    snnList = []; //init snn list
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Center(child: Text("Scan SNN")),
          backgroundColor: Colors.red,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  if(snnList.isNotEmpty){
                    nextPageSave();
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => NextPage()));}
                  else{
                    Fluttertoast.showToast(
                        msg: 'Scan a SNN First',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0
                    );
                  }

                },
                icon: const Icon(
                  Icons.check,
                  color: Colors.white,
                )),
          ],
        ),
        body: Column(
          children: [
            Container(
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 8),
                padding: const EdgeInsets.all(3.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)),
                child: Text(
                  "DNN is " + widget.dnnCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                )),
            Container(
                margin: const EdgeInsets.fromLTRB(15, 5, 15, 8),
                padding: const EdgeInsets.all(3.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)),
                child: Text(
                  "EAN is " + widget.eanCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                )),

            Container(
                height: 250, width: 250, child: _buildQrView(context)),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                child:
                    Text("Scan Next EAN", style: TextStyle(fontSize: 20)),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(15, 5, 15, 5)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.red)))),
                onPressed: () {
                  saveData();
                  int count = 0;
                  Navigator.popUntil(context, (route) {
                    return count++ == 3;
                  });
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EANScan(widget.dnnCode)));
                }),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 0, 8.0, 15),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snnList.length,
                  itemBuilder: (context, i) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.black),
                        ),
                      ),
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text((snnList.length - i ).toString(),
                                  style: TextStyle(fontSize: 18)),
                            ),
                            flex: 1,
                          ),
                          Expanded(
                            child: Text(snnList.reversed.toList()[i],
                                style: TextStyle(fontSize: 18)),
                            flex: 5,
                          ),
                          Expanded(
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  snnList.removeAt(snnList.length - i -1);
                                });

                              },
                            ),
                            flex: 1,
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  saveData() async {
    // Constants.DATA_MAP[widget.eanCode] = snnList;
    var data = Map();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = (prefs.getString(Constants.DATA_EAN) ?? '');

    if (jsonData != '') {
      data = json.decode(jsonData);
    }
    data[widget.eanCode] = snnList;
    await prefs.setString(Constants.DATA_EAN, json.encode(data));
    print('snn_scan' + prefs.getString(Constants.DATA_EAN)!);
  }

  nextPageSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ean_data = (prefs.getString(Constants.DATA_EAN) ?? '');
    print("initial : " + ean_data);
    String current_dnn = (prefs.getString(Constants.CURRENT_DNN) ?? '');
    String current_output = (prefs.getString(Constants.CURRENT_OUTPUT) ?? '');

    var data;
    if (ean_data != '') {
      data = json.decode(ean_data);
      print('initial data : ' + data.toString());
    } else {
      data = Map();
      print('else');
    }
    data[widget.eanCode] = snnList;
    print('final data : ' + data.toString());
    await prefs.setString(Constants.DATA_EAN, json.encode(data));
    print('snn_scan' + prefs.getString(Constants.DATA_EAN)!);

    var data_output = Map();
    if (current_output != '') {
      data_output = json.decode(current_output);
    }
    data_output[current_dnn] = data;
    var output = json.encode(data_output);
    await prefs.setString(Constants.CURRENT_OUTPUT, output);
    print('output : ' + output);
  }

  Widget _buildQrView(BuildContext context) {
    // For Scan area
    var scanArea = MediaQuery.of(context).size.width - 20;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 5,
          borderLength: 50,
          borderWidth: 5,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!snnList.contains(scanData.code)) {
        setState(() {
          snnList.add(scanData.code);
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
