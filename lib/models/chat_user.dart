class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAd,
    required this.lastActive,
    required this.id,
    required this.isOnline,
    required this.pushToken,
    required this.email,
  });
  late String image;
  late String about;
  late String name;
  late String createdAd;
  late String lastActive;
  late String id;
  late bool isOnline;
  late String pushToken;
  late String email;

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAd = json['created_ad'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'];
    isOnline = json['is_online'] ?? false;
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_ad'] = createdAd;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    data['email'] = email;
    return data;
  }
}
