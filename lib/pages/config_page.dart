//Configuration page
import 'package:barcode_scanner/model/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config extends StatefulWidget {
  const Config({Key? key}) : super(key: key);

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  bool is_edit = false;
  TextEditingController urlController = TextEditingController();
  TextEditingController devIdController = TextEditingController();
  TextEditingController keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // get shared pref data
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Center(child: Text("Configuration")),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              if (is_edit == true) { //if in editing state
                saveData(); //Save data in Shared Preferences
                Navigator.pop(context);
              }
              setState(() {
                is_edit = !is_edit; //change state for icon change and allow to edit fields or lock it
              });
            },
            icon: is_edit //change icon according to state
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                  enabled: is_edit,
                  controller: urlController,
                  autofocus: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter API-URL',
                      label: Text('URL')),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter API-URL';
                    }
                  }),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                  enabled: is_edit,
                  controller: devIdController,
                  autofocus: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Device-ID',
                      label: Text('Device-ID')),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter device ID';
                    }
                  }),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                  enabled: is_edit,
                  controller: keyController,
                  autofocus: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Key',
                      label: Text('Key')),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Key';
                    }
                  }),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> saveData() async {
    //Save data in Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.API_URL, urlController.text);
    await prefs.setString(Constants.DEVICE_ID, devIdController.text);
    await prefs.setString(Constants.KEY, keyController.text);
  }

  Future<void> getData() async {
    //Read Shared Preferences data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    urlController.text = prefs.getString(Constants.API_URL) ?? '';
    devIdController.text = prefs.getString(Constants.DEVICE_ID) ?? '';
    keyController.text = prefs.getString(Constants.KEY) ?? '';
  }
}
