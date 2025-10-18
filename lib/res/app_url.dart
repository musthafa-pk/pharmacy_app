class AppUrl{
  // static const port          = '3003';

  // static const hostedip      = '13.232.117.141';
  static const gmap             = 'AIzaSyB--h2bl_kZ_p1FJlRVApPhDziQDkm_gmw';

  // static const localip       = '192.168.1.10';

  // static var baseUrl         = 'http://${hostedip}:${port}/chemist';
  static var baseUrl            = 'https://test.apis.dr1.co.in/chemist';

  static var login              = '$baseUrl/chemist_login';

  static var profile            = '$baseUrl/chemist_profile';

  static var getorders          = '$baseUrl/getorder';

  static var respond            = '$baseUrl/orderResponse';

  static var confirmedOrders    = '$baseUrl/getconfirmedorder';

  static var getProudcuts       = '$baseUrl/getproductspharmacy';

  static var getNotifications   = '$baseUrl/get_notification';

  static var seennotifi         = '$baseUrl/addSeenStatus';

  static var recoverypassword   = '$baseUrl/forgot_password';

  static var verifyOTP          = '$baseUrl/verifyOtp';

  static var changepassword     = '$baseUrl/changePassword';

  static var storeToken         = '$baseUrl/addTokenPh';

  static var orderSummery       = '$baseUrl/orderSummery';

  //requestDelivery
  static var requestDelivery    = '$baseUrl/request_delivery';
  // static var requestDelivery    = 'http://192.168.1.5:3003/chemist/request_delivery';
}