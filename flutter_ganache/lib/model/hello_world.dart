class HelloWorld {
  final String message;

  HelloWorld({required this.message});

  factory HelloWorld.fromJson(Map<String, dynamic> json) {
    return HelloWorld(
      message: json['message'],
    );
  }
}
