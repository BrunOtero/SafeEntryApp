enum UserType {
  morador,
  porteiro,
  admin;

  String toJson() => name;

  factory UserType.fromJson(String json) {
    return UserType.values.firstWhere((element) => element.name == json);
  }
}