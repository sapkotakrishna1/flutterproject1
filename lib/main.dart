import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart'; // Import Khalti SDK
import 'login.dart'; // Import the login.dart file
import 'reg.dart'; // Import the registration page if you have one
import 'paymentsuc.dart'; // Add your payment success page (you may need to create this page)
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization

void main() {
  runApp(const Restore());
}

class Restore extends StatelessWidget {
  const Restore({super.key});

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: '6b65ce324568434bb08d6d51a88e5c18', // Your Khalti public key
      builder: (context, navigatorKey) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Restore',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const LoginPage(),
          routes: {
            '/reg': (context) => const RegisterPage(),
            '/kpg': (context) => const PaymentSuccessPage(),
          },
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('ne', 'NP'), // Nepali
          ],
        );
      },
    );
  }
}
