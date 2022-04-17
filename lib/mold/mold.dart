import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mold/common/logger.dart';
import 'package:flutter_mold/localization/app_lang.dart';
import 'package:flutter_mold/mold/mold_application.dart';
import 'package:flutter_mold/mold/style.dart';
import 'package:flutter_mold/mold2/arg_data.dart';
import 'package:flutter_mold/mold2/bundle.dart';
import 'package:flutter_mold/mold2/window.dart';

class Mold {
  static void startApplication(
    MoldApplication application, {
    List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
    void onError(Object error, StackTrace stack)?,
  }) {
    runZonedGuarded(() {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(
        MoldApplicationWidget((_) {
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            final colors = MoldStyle.instance.color!;
            Future.delayed(Duration(milliseconds: 50))
                .then((_) => SystemChrome.setSystemUIOverlayStyle(colors.systemStyle));
            return getPlatformApp(application, colors, navigatorObservers);
          });
        }, application),
      );
    }, (error, st) {
      Log.error(error, st);
      onError?.call(error, st);
    });
  }

  static StatefulWidget getPlatformApp(
    MoldApplication application,
    MoldColor color,
    List<NavigatorObserver> navigatorObservers,
  ) {
    AppLang appLang = App.appLang;
    if (kIsWeb) {
      return MaterialApp(
        theme: ThemeData(
          brightness: color.brightness,
          toggleableActiveColor: color.appColor,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(brightness: color.brightness, secondary: color.appColor),
        ),
        routes: application.getRoutes(),
        locale: appLang.getLocale(),
        supportedLocales: appLang.getSupportLangs(),
        navigatorObservers: navigatorObservers,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
    } else if (Platform.isIOS) {
      return CupertinoApp(
        theme: CupertinoThemeData(
          brightness: color.brightness,
          primaryColor: color.appColor,
          primaryContrastingColor: color.appColor,
        ),
        routes: application.getRoutes(),
        locale: appLang.getLocale(),
        supportedLocales: appLang.getSupportLangs(),
        navigatorObservers: navigatorObservers,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
    } else {
      return MaterialApp(
        theme: ThemeData(
          brightness: color.brightness,
          toggleableActiveColor: color.appColor,
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(brightness: color.brightness, secondary: color.appColor),
        ),
        routes: application.getRoutes(),
        locale: appLang.getLocale(),
        supportedLocales: appLang.getSupportLangs(),
        navigatorObservers: navigatorObservers,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
    }
  }

  static Widget newInstance(Object content) {
    if (content is Screen) {
      return new Window(content);
    } else {
      throw new UnsupportedError("cannot create instance content type unsupported");
    }
  }

  static void openContent<R>(
    BuildContext context,
    dynamic content, {
    Bundle? bundle,
    void onPopResult(R? result)?,
  }) {
    Bundle? argumentBundle = bundle;
    if (argumentBundle == null) {
      argumentBundle = Bundle.newBundle(context);
    }

    // if (content is RootFragment) {
    //   push = Navigator.push<R>(
    //     context,
    //     new MaterialPageRoute(builder: (_) => Mold.newInstance(content..argument = argumentBundle)),
    //   );
    // } else
    Future<R?> push;
    if (content is String) {
      push = Navigator.pushNamed(
        context,
        content,
        arguments: ScreenArgument(argumentBundle),
      );
    } else {
      throw new UnsupportedError("cannot openContent content not support");
    }

    push.then((value) => onPopResult?.call(value));
  }

  static void replaceContent<R>(
    BuildContext context,
    dynamic content, {
    Bundle? bundle,
    void onPopResult(R? result)?,
  }) {
    Bundle? argumentBundle = bundle;
    if (argumentBundle == null) {
      argumentBundle = Bundle.newBundle(context);
    }

    // if (content is RootFragment) {
    //   push = Navigator.pushAndRemoveUntil<R>(
    //     context,
    //     new MaterialPageRoute(builder: (_) => Mold.newInstance(content..argument = argumentBundle)),
    //     (routes) => false,
    //   );
    // } else
    Future<R?> push;
    if (content is String) {
      push = Navigator.pushNamedAndRemoveUntil(
        context,
        content,
        (routes) => false,
        arguments: ScreenArgument(argumentBundle),
      );
    } else {
      throw new UnsupportedError("cannot replaceContent content not support");
    }

    push.then((value) => onPopResult?.call(value));
  }

  static void onBackPressed<T extends Object>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  static void hideKeyboard() {
    /*
   // bunda Screen onCreate chaqirib yuboribdi shuning uchun quyidagicha yechim qilindi.
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus.unfocus();
    }*/
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (error, st) {
      Log.error(error, st);
    }
  }

  static void focusKeyboard(BuildContext context, [FocusNode? node]) {
    FocusScope.of(context).requestFocus(node);
  }
}
