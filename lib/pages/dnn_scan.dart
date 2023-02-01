//DNN scan page
import 'package:barcode_scanner/model/constants.dart';
import 'package:barcode_scanner/pages/ean_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scan/scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DNNScan extends StatefulWidget {
  const DNNScan({Key? key}) : super(key: key);

  @override
  _DNNScanState createState() => _DNNScanState();
}

class _DNNScanState extends State<DNNScan> {
  //Barcode scanning api init
  ScanController controller = ScanController();
  //Current DNN
  String dnnCode = '';

  @override
  void initState() {
    super.initState();
    // Reset temporary value of Current DNN, EAN, SNN that has been saved to shared pref
    resetSharedValue();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Center(child: Text("Scan DNN")),
          backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  "Delivery Note Number",
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
                  onCapture: (data) async {
                    setState(() {
                      dnnCode = data;
                      print(data);
                    });
                    //save data temporarily in share preference
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString(Constants.CURRENT_DNN, dnnCode);
                  },
                ),
              ),
              if (dnnCode.isNotEmpty)
                Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)),
                    child: Text('DNN is $dnnCode')),

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
                        onPressed: () async {
                          //Check if nothing scanned
                          if (dnnCode != '') {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EANScan(dnnCode)));
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Scan a DNN First',
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

  // Reset temporary value of Current DNN, EAN, SNN that has been saved to shared pref
  Future<void> resetSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dnnCode = '';
    });
    await prefs.setString(Constants.DATA_EAN, '');
    await prefs.setString(Constants.CURRENT_DNN, '');
  }
}
