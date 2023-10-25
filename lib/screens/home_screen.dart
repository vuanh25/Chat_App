import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/api/api.dart';
import 'package:chatapp/helper/dialog.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/screens/profile_screen.dart';
import 'package:chatapp/widgets/chat_user_card.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> searchlist = [];
  bool _isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
          onWillPop: () {
            if (_isSearching) {
              setState(() {
                _isSearching = !_isSearching;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              leading: const Icon(CupertinoIcons.home),
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name,Email, ...'),
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, letterSpacing: 1),
                      onChanged: (val) {
                        searchlist.clear();
                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) &&
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            searchlist.add(i);
                          }
                          setState(() {
                            searchlist;
                          });
                        }
                      },
                    )
                  : const Text('App Chat'),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () async {
                  _addChatUserDialog();
                },
                child: const Icon(
                  Icons.add_comment_rounded,
                ),
              ),
            ),
            body: StreamBuilder(
              stream: APIs.getMyUsersId(),

              //get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  //if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                      //get only those user, who's ids are provided
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          // return const Center(
                          //     child: CircularProgressIndicator());

                          //if some or all data is loaded then show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? searchlist.length
                                      : list.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                        user: _isSearching
                                            ? searchlist[index]
                                            : list[index]);
                                  });
                            } else {
                              return const Center(
                                child: Text('No Connections Found!',
                                    style: TextStyle(fontSize: 20)),
                              );
                            }
                        }
                      },
                    );
                }
              },
            ),
          )),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User'),
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  hintText: 'Email Id',
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.blue,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                // add button
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackbar(context, 'User not found!');
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ));
  }
}
