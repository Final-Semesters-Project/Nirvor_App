class   AppStrings {
  static RegExp passRegexp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.{8,}$)');
  static RegExp emailRegexp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static const String fieldCantBeEmpty = "Field can't be empty";
  static const String emailFieldCantBeEmpty = "Please enter your email";
  static const String passwordFieldCantBeEmpty = "Please enter your password";
  static const String checknetworkconnection = "Check network connection";
  static const String enterThe8Character = "Please Enter The 8 character";
  static const String passwordNotMatch = "Passwords do not match";
  static const String resetPassword = "Reset Password";

  //================== Custom Controller String ===================//
  static const String getStarted = "Get Started";
  static const String welcomeBack = "Welcome Back";
  static const String welcomeBackTitle = "Please login to your account";
  static const String email = "Email";
  static const String enterYourEmail = "Enter your email";
  static const String name = "Name";
  static const String enterName = "Enter a name";
  static const String exampleEmail = "example@ex.com";
  static const String phoneNumber = "Phone Number";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";
  static const String passwordHint = "******";
  static const String enterYourPassword = "Enter your password";
  static const String forgetPassword = "Forget Password?";
  static const String changePassword = "Change Password";
  static const String currentPassword = "Current Password";
  static const String newPassword = "New Password";
  static const String retypePassword = "Retype Password";
  static const String number = "Number";
  static const String dateOfBirthday = "Date of Birthday";
  static const String signInWithGoogle = "Sign in with Google";
  static const String login = "Login";
  static const String logout = "Logout";
  static const String doNtHaveAccount = "Don’t have an account? ";
  static const String alreadyHaveAccount = "Already have an account? ";
  static const String signUp = "Sign up";
  static const String createYourAccount = "Create your account by email";
  static const String continueText = "Continue";
  static const String saveChanges = "Save Changes";
  static const String chooseYourRole = "Choose Your Role";
  static const String chooseYourRoleTitle = "What type of account you want?\nWho are you? Select an option\nto continue";

  ///============================ Common Auth =========================//

  static const String search = "Search";
  static const String submit = "Submit";
  static const String createAPost = "Create a Post";
  static const String createAStory = "Create a Story";
  static const String messageList = "Message List";
  static const String typeYourDate = "typeYourDate";
  static const String forgotTitle = "Enter your email account to reset  your password";


}
