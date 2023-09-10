class User {
  int userId;
  String username;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? address;
  String? phoneNumber;

  User({
    this.userId = 0,
    required this.username,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.address,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'phone_number': phoneNumber,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      address: map['address'],
      phoneNumber: map['phone_number'],
    );
  }
}
