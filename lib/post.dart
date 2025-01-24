class Post {
  final int postid; // ID of the object
  final int comments_id;
  final String username; // User who created the post
  final String email; // Email of the user who created the post
  final String name; // Name of the object
  final String description; // Description of the object
  final String imageUrl; // URL of the object's image
  final double price; // Price of the object
  final int age; // Age of the object
  final String createAt; // Creation date/time of the object

  Post({
    required this.postid,
    required this.comments_id,
    required this.username,
    required this.email,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.age,
    required this.createAt,
  });

  // Factory constructor to create a Post object from a JSON response
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      comments_id: json['comments_id'], // Assuming the JSON has this field
      postid: json['id'], // Assuming the JSON has this field
      username: json['username'], // Assuming the JSON has this field
      email: json['email'], // Assuming the JSON has this field
      name: json['name'], // Assuming the JSON has this field
      description: json['description'], // Assuming the JSON has this field
      imageUrl: json['image'], // Assuming the JSON has this field
      price: json['price'].toDouble(), // Assuming the JSON has this field
      age: json['age'], // Assuming the JSON has this field
      createAt: json['create_at'], // Assuming the JSON has this field
    );
  }
}
