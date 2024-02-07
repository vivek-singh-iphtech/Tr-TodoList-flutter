import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesList extends StatefulWidget {
  final void Function(BuildContext context, bool isUpdate,
      DocumentSnapshot? documentSnapshot) showBottomSheet;

  const NotesList({Key? key, required this.showBottomSheet, required uid}) : super(key: key);

  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  final db = FirebaseFirestore.instance;
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255, // Alpha value
      random.nextInt(256), // Red value
      random.nextInt(256), // Green value
      random.nextInt(256), // Blue value
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50), topRight: Radius.circular(50)),
      child: Container(
        color: Color.fromARGB(255, 254, 229, 206),
        child: StreamBuilder(
          stream: db.collection('TodoList').snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, int index) {
                DocumentSnapshot documentSnapshot = snapshot.data.docs[index];

                return Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: GestureDetector(
                    onTap: () {
                      widget.showBottomSheet(context, true, documentSnapshot);
                    },
                    child: Container(
                      width: 250,
                      height: 140,
                      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 189, 189, 189).withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 3, // Blur radius
            offset: Offset(0, 3), // Shadow offset
          ),
        ],
      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 190, // Width of the colored strip
                              decoration: BoxDecoration(
                                color: getRandomColor(),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 5, // Distance from left for the card
                            top: 0, // Distance from top for the card
                            right: 0,
                            bottom: 0,

                            child: Container(
                              width: 170,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(
                                    255, 255, 255, 255), // Color of the strip
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        documentSnapshot['Title'],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Container(
                                        width: 200,
                                        child: Text(
                                           _truncateTitle(documentSnapshot['Description'], 15),
                                          
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      db
                                          .collection('TodoList')
                                          .doc(documentSnapshot.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

   String _truncateTitle(String title, int words) {
    List<String> titleWords = title.split(' ');
    if (titleWords.length <= words) {
      return title;
    } else {
      return titleWords.sublist(0, words).join(' ');
    }
  }
}
