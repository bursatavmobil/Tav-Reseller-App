import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/features/auth/screens/splash_screen.dart';
import 'package:reseller_app_tav/features/dashboard/providers/dashboard_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/profile_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/stock_car_provider.dart';
import 'package:reseller_app_tav/features/dashboard/providers/visit_schedule_provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch(e){
    throw Exception("Error Load .env : $e");
  }
  await initializeDateFormatting('id_ID', null);
  await FlutterDownloader.initialize(
    debug: false, 
    ignoreSsl: true, 
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => VisitScheduleProvider()),
        ChangeNotifierProvider(create: (_) => StockCarProvider()),
        ChangeNotifierProvider(create: (_) => NegotiationProvider()),
      ],
      child: const ResellerApp(),
    ),
  );
}

class ResellerApp extends StatelessWidget {
  const ResellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reseller App Tav Mobil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
