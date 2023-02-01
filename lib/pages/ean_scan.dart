//EAN scanning page

import 'package:barcode_scanner/pages/snn_scan.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scan/scan.dart';

class EANScan extends StatefulWidget {
  String dnnCode;

  EANScan(this.dnnCode);

  @override
  _EANScanState createState() => _EANScanState();
}

class _EANScanState extends State<EANScan> {
  //Barcode scanning api init
  ScanController controller = ScanController();
  //Current EAN
  String eancode = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Center(child: Text("Scan EAN")),
          backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(15, 5, 15, 8),
                  padding: const EdgeInsets.all(3.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)),
                  child: Text(
                    "DNN code is " + widget.dnnCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  )),
              const Center(
                child: Text(
                  "Scan EAN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              //Scanning part
              SizedBox(
                width: 250,
                height: 250,
                child: ScanView(
                  controller: controller,
                  scanAreaScale: .95,
                  scanLineColor: Colors.green.shade400,
                  onCapture: (data) {
                    setState(() {
                      eancode = data;
                      print(data);
                    });
                  },
                ),
              ),
              if (eancode.isNotEmpty)
                Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)),
                    child: Text('EAN is $eancode')),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        child: Row(
                          children: const [
                            Text("Rescan", style: TextStyle(fontSize: 20)),
                            Icon(
                              Icons.refresh,
                              color: Colors.white,
                            )
                          ],
                        ),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.fromLTRB(15, 5, 15, 5)),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.red)))),
                        onPressed: () {
                          controller.resume();
                        }),
                    TextButton(
                        child: Row(
                          children: const [
                            Text("Next", style: TextStyle(fontSize: 20)),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.white,
                            )
                          ],
                        ),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.fromLTRB(15, 5, 15, 5)),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.red)))),
                        onPressed: () {
                          if (eancode != '') {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SNNScan(widget.dnnCode, eancode)));
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Scan a EAN First',
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                fontSize: 16.0);
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
