import 'dart:js';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';
import 'package:decideup/RootService.dart';
import 'package:decideup/src/domain/LoginResult.dart';
import 'package:decideup/src/firebase/DecideFire.dart';
import 'package:decideup/src/navigation/route_paths.dart';
import 'package:decideup/src/services/DomainService.dart';

@Component(
  selector: 'login',
  templateUrl: 'login.html',
  directives: [coreDirectives, formDirectives, AutoFocusDirective],
  styleUrls: ['login.css'],
)
class Login implements OnActivate{
  final RootService rootService;
  final DatabaseService databaseService;

  final Router router;

  @ViewChild('loginForm') NgForm loginForm;
  @ViewChild('email') NgControl emailInput;

  String email;
  String displayName;
  String password;

  String welcomeText = "Sign In";
  String buttonText = "Next";

  bool showPassword = false;
  bool showName = false;

  bool showEmailError = false;
  String emailError = "";

  bool showPasswordError = false;
  String passwordError = "";

  Login(this.rootService, this.router, this.databaseService);

  @override
  void onActivate(RouterState previous, RouterState current) {
    rootService.showLogin = false;
    bool isSignUp = current.parameters["isSignUp"] == "true" ? true : false;
    if(isSignUp) {
      welcomeText = "Create an Account";
    } else {
      welcomeText = "Sign In";
    }
  }

  void next() async {
    DecideFire fire = new DecideFire();
    if(showPassword && showName) {
      rootService.showLoading = true;
      LoginResult result = await databaseService.user.signup(email, password, displayName);
      rootService.showLoading = false;
      if(result.error != null) {
        showPasswordError = true;
        passwordError = result.error.message();
      } else {
        this.router.navigate(RoutePaths.dashboard.toUrl());
        this.rootService.isUserLoggedIn = true;
      }
    } else if(showPassword) {
      rootService.showLoading = true;
      LoginResult result = await databaseService.user.login(email, password);
      rootService.showLoading = false;
      if(result.error != null) {
        showPasswordError = true;
        passwordError = result.error.message();
      } else {
        this.router.navigate(RoutePaths.dashboard.toUrl());
        this.rootService.isUserLoggedIn = true;
      }
    } else {
      try {
        List<String> methods = await fire.checkEmail(this.email);
        showEmailError = false;
        showPassword = true;
        if (methods.length == 0) {
          buttonText = "Sign Up";
          showName = true;
        } else {
          buttonText = "Log In";
        }
      } catch(error) {
        showEmailError = true;
        emailError = error.toString();
      }
    }
  }
}
