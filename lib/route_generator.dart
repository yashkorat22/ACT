import 'package:act/src/pages/Locations/EditLocation.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import 'src/models/classEvent.dart';
import 'src/models/subscription.dart';
import 'src/models/shoppingCart.dart';
import 'src/models/location.dart';

import 'src/pages/Auth/Splash.dart';
import 'src/pages/Auth/Login.dart';
import 'src/pages/Auth/SignUp.dart';
import 'src/pages/Auth/Terms.dart';
import 'src/pages/Auth/Confirm.dart';
import 'src/pages/Auth/ForgotPassword.dart';

import 'src/pages/Home/Home.dart';
import 'src/pages/Home/Profile.dart';

import 'src/pages/Members/Members.dart';
import 'src/pages/Members/CreateMember.dart';
import 'src/pages/Members/EditMember.dart';

import 'src/pages/Classes/CRUD/Classes.dart';
import 'src/pages/Classes/CRUD/DiscoverClass.dart';
import 'src/pages/Classes/CRUD/CreateTrainingClass.dart';
import 'src/pages/Classes/CRUD/EditTrainingClass.dart';
import 'src/pages/Classes/CRUD/ClassAvatarList.dart';

import 'src/pages/Classes/Manage/ManageClass.dart';
import 'src/pages/Classes/Manage/CreateClassEvent.dart';
import 'src/pages/Classes/Manage/EditClassEvent.dart';
import 'src/pages/Classes/Manage/ManageCalendarEvent.dart';
import 'src/pages/Classes/Manage/CalendarEventInformation.dart';

import 'src/pages/Subscriptions/Subscriptions.dart';
import 'src/pages/Subscriptions/ManageSubscriptions.dart';
import 'src/pages/Subscriptions/CreateSingleSubscription.dart';
import 'src/pages/Subscriptions/ManageSingleSubscription.dart';

import 'src/pages/ShoppingCarts/ShoppingCarts.dart';
import 'src/pages/ShoppingCarts/ManageSingleShoppingCart.dart';

import 'src/pages/Events/Events.dart';

import 'src/pages/Locations/Locations.dart';
import 'src/pages/Locations/CreateLocation.dart';
import 'src/pages/Locations/PickAddress.dart';
import 'src/pages/Locations/LocationDetail.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
        return MaterialPageRoute(
            builder: (_) => UpgradeAlert(
                  debugLogging: true,
                  child: SplashScreen(),
                ));
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/Terms':
        return MaterialPageRoute(builder: (_) => TermsWidget());
      case '/Confirm':
        return MaterialPageRoute(builder: (_) => ConfirmWidget());
      case '/ForgotPassword':
        return MaterialPageRoute(builder: (_) => ForgotPasswordWidget());
      case '/':
      case '/Home':
        return MaterialPageRoute(
            builder: (_) => UpgradeAlert(
                  debugLogging: true,
                  child: HomeWidget(),
                ));
      case '/Profile':
        return MaterialPageRoute(builder: (_) => ProfileWidget());
      case '/Members':
        return MaterialPageRoute(builder: (_) => MembersWidget());
      case '/CreateMember':
        return MaterialPageRoute(builder: (_) => CreateMemberWidget());
      case '/EditMember':
        return MaterialPageRoute(builder: (_) => EditMemberWidget());
      case '/Classes':
        return MaterialPageRoute(builder: (_) => ClassesWidget());
      case '/CreateTrainingClass':
        return MaterialPageRoute(builder: (_) => CreateTrainingWidget());
      case '/EditTrainingClass':
        return MaterialPageRoute(builder: (_) => EditTrainingWidget());
      case '/ClassAvatarList':
        return MaterialPageRoute(builder: (_) => ClassAvatarList());
      case '/ManageClass':
        return MaterialPageRoute(builder: (_) => ManageClass());
      case '/CreateClassEvent':
        return MaterialPageRoute(
            builder: (_) =>
                CreateClassEventWidget(selectedDate: args as DateTime?));
      case '/CreateLocation':
        return MaterialPageRoute(builder: (_) => CreateLocationWidget());
      case '/EditClassEvent':
        return MaterialPageRoute(builder: (_) => EditClassEventWidget());
      case '/ManageCalendarEvent':
        return MaterialPageRoute(
            builder: (_) =>
                ManageCalendarEventWidget(event: args as ClassEvent?));
      case '/Subscriptions':
        return MaterialPageRoute(builder: (_) => SubscriptionsWidget());
      case '/ManageSingleMemberSubscription':
        return MaterialPageRoute(
            builder: (_) => ManageSubscriptionsWidget(memberId: args as int?));
      case '/CreateSingleSubscription':
        return MaterialPageRoute(
            builder: (_) => CreateSingleSubscriptionWidget(memberId: args));
      case '/ManageSingleSubscription':
        return MaterialPageRoute(
            builder: (_) => ManageSingleSubscriptionWidget(
                  subscriptionInfo: args as Subscription?,
                ));
      case '/ShoppingCarts':
        return MaterialPageRoute(builder: (_) => ShoppingCartsWidget());
      case '/ManageSingleShoppingCart':
        return MaterialPageRoute(
            builder: (_) => ManageSingleShoppingCartWidget(
                  shoppingCartInfo: args as ShoppingCart?,
                ));
      case '/DiscoverClass':
        return MaterialPageRoute(builder: (_) => DiscoverClassWidget());
      case '/Events':
        return MaterialPageRoute(builder: (_) => EventsWidget());
      case '/Locations':
        return MaterialPageRoute(builder: (_) => LocationsWidget());
      case '/PickAddress':
        return MaterialPageRoute(
            builder: (_) => PickAddressWidget(location: args as ActLocation));
      case '/LocationDetail':
        return MaterialPageRoute(
            builder: (_) =>
                LocationDetailWidget(location: args as ActLocation));
      case '/EditLocation':
        return MaterialPageRoute(
            builder: (_) => EditLocationWidget(location: args as ActLocation));
      case '/CalendarEventInformation':
        return MaterialPageRoute(
            builder: (_) =>
                CalendarEventInformationWidget(event: args as ClassEvent?));
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                body: SafeArea(
                    child: Text('Route Error: "' + settings.name! + '"'))));
    }
  }
}
