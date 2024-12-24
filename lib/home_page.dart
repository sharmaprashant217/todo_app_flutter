import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_database/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Notes')),
        backgroundColor: Colors.blue,
      ),
      //all notes viewed here
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index+1}'),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          child: Icon(Icons.edit),
                          onTap: () {
                            titleController.text = allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                            descController.text = allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return getBottomSheetWidget(isUpdate: true, sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                                });
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onTap: ()async{
                            bool check = await dbRef!.deleteNote(s_no: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                            if(check){
                              getNotes();
                            }

                          },
                        )
                      ],
                    ),
                  ),
                );
              })
          : Center(
              child: Text("No Notes Yet"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          descController.clear();
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return getBottomSheetWidget();
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    // note to be added from here
    return Container(
      padding: EdgeInsets.all(11),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            isUpdate ? 'Update Note' : 'Add Note',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 21,
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                enabled: true,
                hintText: "Enter Title Here",
                labelText: "Title*",
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                )),
          ),
          SizedBox(
            height: 21,
          ),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
                enabled: true,
                hintText: "Enter Description Here",
                labelText: "Description*",
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11))),
          ),
          SizedBox(
            height: 21,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        )),
                    onPressed: () async {
                      var title = titleController.text;
                      var desc = descController.text;
                      if (title.isNotEmpty && desc.isNotEmpty) {
                        bool check = isUpdate
                            ? await dbRef!.updateNote(
                            mTitle: title, mDesc: desc, s_no: sno)
                            : await dbRef!
                            .addNote(mTitle: title, mDesc: desc);
                        if (check) {
                          getNotes();
                        }
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Please fill required fields"),
                        ));
                      }
                    },
                    child: Text(isUpdate ? "Update Note" : "Add Note")),
              ),
              SizedBox(
                width: 11,
              ),
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                            side: BorderSide(width: 1))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
              )
            ],
          ),
        ],
      ),
    );
  }
}
