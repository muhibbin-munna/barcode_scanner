//Manual send page

import 'package:barcode_scanner/db/offline_database.dart';
import 'package:barcode_scanner/model/note.dart';
import 'package:barcode_scanner/pages/home_screen.dart';
import 'package:barcode_scanner/widget/note_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ManualSend extends StatefulWidget {
  const ManualSend({Key? key}) : super(key: key);

  @override
  _ManualSendState createState() => _ManualSendState();
}

class _ManualSendState extends State<ManualSend> {
  late List<Note> notes; //Offline database model
  bool isLoading = false; //For fetching time loading pop up show

  @override
  void initState() {
    super.initState();
    refreshNotes(); //Refresh data

  }

  //Get data from databse
  Future refreshNotes() async {
    setState(() => isLoading = true);
    this.notes = await OfflineDatabase.instance.readAllNotes();
    setState(() => isLoading = false);
    if(notes.isEmpty ){ //if there is no data then go to home page
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => HomeScreen()),
              (route) => false);
    }

  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Unsent Data',
      ),
      backgroundColor: Colors.red,
      elevation: 0,
      // actions: [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? CircularProgressIndicator()
          : notes.isEmpty
          ? Text(
        'No Notes',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
          : buildNotes(),
    ),
  );

  // widget to show offline data
  Widget buildNotes() => StaggeredGridView.countBuilder(
    padding: EdgeInsets.all(8),
    itemCount: notes.length,
    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    crossAxisCount: 1,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    itemBuilder: (context, index) {
      final note = notes[index];

      return NoteCardWidget(note: note, index: index , notifyParent: refreshNotes ); //for every single data
    },
  );
}

