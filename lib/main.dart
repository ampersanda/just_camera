import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_camera/colors.dart';
import 'package:just_camera/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Flutter Demo',
      color: Colors.white,
      initialRoute: 'home',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          default:
            return PageRouteBuilder<Widget>(pageBuilder: (BuildContext context,
                Animation<double> pAnimation, Animation<double> sAnimation) {
              return const HomeScreen();
            });
        }
      },
    );
  }
}
