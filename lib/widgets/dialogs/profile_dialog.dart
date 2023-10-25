import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(children: [
          Positioned(
            top: mq.height * .075,
            left: mq.width * .1,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  imageUrl: user.image,
                  width: mq.width * .5,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                )),
          ),
          Positioned(
            left: mq.width * .04,
            top: mq.height * .02,
            width: mq.width * .55,
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfileScreen(user: user)));
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 30,
                ),
              ))
        ]),
      ),
    );
  }
}
