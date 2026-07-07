import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  /// Represents a user in the application.
  /// Contains user details such as uid, name, email, and photoUrl.
  final String? uid;
  final String? name;
  final String? email;
  final String? photoUrl;

  AppUser({this.uid, this.name, this.email, this.photoUrl});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    name: json['name'],
    email: json['email'],
    photoUrl: json['photoUrl'],
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
  };

  @override
  List<Object?> get props => [uid, name, email, photoUrl];
}
