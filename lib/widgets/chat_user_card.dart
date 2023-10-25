import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/message.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                message = list[0];
              }
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(
                              user: widget.user,
                            ));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      //   placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  message != null
                      ? message!.type == Type.image
                          ? 'Image'
                          : message!.msg
                      : widget.user.about,
                  maxLines: 1,
                ),
                trailing: message == null
                    ? null
                    : message!.read.isEmpty && message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: message!.sent),
                            style: const TextStyle(color: Colors.black45),
                          ),
              );
            },
          )),
    );
  }
}
