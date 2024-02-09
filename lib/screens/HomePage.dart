import 'package:firebase_app/screens/firstscreen.dart';
import 'package:firebase_app/services/PushNotificationService.dart';
import 'package:firebase_app/widgets/notes_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({Key? key, required this.user}) : super(key: key);
  


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  FCM notificationservices = FCM();

  @override
  void initState() {
    super.initState();
    notificationservices.requestNotificartionPermissions();
    notificationservices.FirebaseInit();
    notificationservices.isTokenRefresh();
    notificationservices.getDeviceToken().then((value) => print(value));
  }

  final db = FirebaseFirestore.instance;
  String? titleValue;
  String? descriptionValue;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Firstscreen()),
            (route) => false));
  }

  void showBottomSheet(
      BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color.fromARGB(255, 255, 253, 251),
      builder: (context) =>
          _buildBottomSheetContent(context, isUpdate, documentSnapshot),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo List',
          style: TextStyle(
            color: const Color.fromARGB(255, 39, 39, 39),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
               style: ButtonStyle(
                     
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 254, 173, 74)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(10),
                      ),
                      
                    ),
                onPressed: () {
                  _signOut();
                },
                child: Text('Logout',style: TextStyle(
                  color: Colors.white,
                ),)),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () {
          showBottomSheet(context, false, null);
        },
        label: const Text(
          'Add',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: NotesList(
        showBottomSheet: showBottomSheet, uid: widget.user.uid,
      ),
    );
  }

  Widget _buildBottomSheetContent(
      BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
    
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

   
    if (isUpdate && documentSnapshot != null) {
      titleController.text = documentSnapshot['Title'];
      descriptionController.text = documentSnapshot['Description'];
    }

    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(
                color: Colors.black, // Set text color to black
              ),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Set border color to black
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Set border color to black
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Set border color to black
                  ),
                ),
                labelText: 'Add Title',
                labelStyle: TextStyle(
                  color: Colors.black, // Set label text color to black
                ),
                hintText: 'Enter A Title',
              ),
              onChanged: (String _val) {
                titleValue = _val;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextField(
                controller: descriptionController,
                style: const TextStyle(
                  color: Colors.black, // Set text color to black
                ),
                cursorColor: Colors.black,
                minLines: 3,
                maxLines: null, // Allows for unlimited lines of input
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      width: 0.8,
                      color: Colors.black, // Set border color to black
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      width: 0.8,
                      color: Colors.black, // Set border color to black
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      width: 0.8,
                      color: Colors.black, // Set border color to black
                    ),
                  ),
                  labelText:
                      'Add Description', // Change label text to 'Add Description'
                  labelStyle: TextStyle(
                    color: Colors.black, // Set label text color to black
                  ),
                  hintText:
                      'Enter A Description', // Change hint text to 'Enter A Description'
                ),
                onChanged: (String _val) {
                  descriptionValue = _val;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 254, 173, 74)),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(10),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (isUpdate && documentSnapshot != null) {
                      documentSnapshot.reference.update({
                        'Title': titleValue,
                        'Description': descriptionValue
                      });
                    } else {
                      // If adding new, add a new document
                      db.collection('TodoList').add({
                        'Title': titleValue,
                        'Description': descriptionValue
                      });
                    }
        
                    Navigator.pop(context);
                  },
                  child: isUpdate
                      ? const Text(
                          'UPDATE',
                          style: TextStyle(color: Colors.white),
                        )
                      : const Text('ADD',
                          style: TextStyle(color: Colors.white))),
            ),
          ],
        ));
  }
}
