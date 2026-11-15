import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/router/app_router.dart';
import 'core/security/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  if (sl.isRegistered<SessionManager>()) {
    sl<SessionManager>().addListener(AppRouter.notifyAuthStateChanged);
    await sl<SessionManager>().initialize();
  }
  runApp(const App());
}
