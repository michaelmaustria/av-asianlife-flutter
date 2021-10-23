
class SignUpRequest {
  String cardNo;
  String apiUser;
  String apiPass;
  String username;
  String userPassword;
  String birthday;
  String lastName;
  String firstName;
  String middleName;
  String mobileNo;
  String email;
  int newsletter; //1 true 0 false
  String deviceId;

  SignUpRequest({this.cardNo,this.apiUser, this.apiPass, this.username, this.userPassword,
      this.birthday, this.lastName, this.firstName, this.middleName,
      this.mobileNo, this.email, this.newsletter, this.deviceId});


}