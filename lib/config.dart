// lib/config.dart
class Config {
  // Define a base URL. You can modify it based on your environment (e.g., dev, prod)
  static String get baseUrl {
    // Modify this logic based on your actual environment switch
    return 'http://172.16.2.32/myapp_api/'; // Local/Development environment    // For production, you can change to a different URL
    // return 'https://yourproductionserver.com/myapp_api/';
  }

  // You can define other useful constants or config here
  static const String login = 'login.php';
  static const String register = 'register.php';
  static const String verifyotpregister = 'verifyotpregister.php';
  static const String addobj = 'addobj.php';
  static const String addcart = 'addcart.php';
  static const String post = 'post.php';
  static const String updatepost = 'update_post.php';
  static const String getuserdata = 'get_user_data.php';
  static const String getpostdata = 'get_post_data.php';
  static const String getcartitems = 'getcartitems.php';
  static const String getcodpurches = 'get_cod_payment.php';
  static const String removecart = 'removecart.php';
  static const String fetchcomment = 'fetchcomment.php';
  static const String fetchreplycomment = 'fetchreplycomment.php';
  static const String verify_payment = 'verify_payments.php';
  static const String codpurches = 'codpurches.php';
  static const String codpurchesemail = 'codpurchesemail.php';
  static const String fetchcodpurches = 'fetchcodpurches.php';
  static const String delete = 'delete.php';
  static const String userdeletedata = 'userdeletedata.php';
  static const String deletepostdata = 'deletepostdata.php';
  static const String deletetdata = 'deletedata.php';
  static const String logoutEndpoint = 'logout.php';
  static const String addcomment = 'addcomment.php';
  static const String replycomment = 'replycomment.php';
}
