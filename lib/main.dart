import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'state/hajj_state.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final prefs = await SharedPreferences.getInstance();
  runApp(ChangeNotifierProvider(create: (_) => HajjController(prefs), child: const HajjApp()));
}

class HajjApp extends StatelessWidget {
  const HajjApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<HajjController, int>((s) => s.themeMode);
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'دليل الحج والعمرة',
      debugShowCheckedModeBanner: false,
      theme: HajjTheme.light(),
      darkTheme: HajjTheme.dark(),
      themeMode: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark][mode.clamp(0, 2)],
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
