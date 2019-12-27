import 'package:flutter/widgets.dart';

class Constants extends InheritedWidget {
  static Constants of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(Constants);

  const Constants({Widget child, Key key}) : super(key: key, child: child);

  final String accessTokenKey = 'access_token';

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
