// lib/config.dart
class Config {
  // Define a base URL. You can modify it based on your environment (e.g., dev, prod)
  static String get baseUrl {
    // Modify this logic based on your actual environment switch
    return 'http://192.168.1.81/myapp_api/'; // Local/Development environment    // For production, you can change to a different URL
    // return 'https://yourproductionserver.com/myapp_api/';
  }

  // You can define other useful constants or config here
  static const String login = 'login.php';
  static const String register = 'register.php';
  static const String verifyotpregister = 'verifyotpregister.php';
  static const String addobj = 'addobj.php';
  static const String post = 'post.php';
  static const String updatepost = 'update_post.php';
  static const String getuserdata = 'get_user_data.php';
  static const String delete = 'delete.php';
  static const String logoutEndpoint = 'logout.php';
  static const String addcomment = 'addcomment.php';
}
