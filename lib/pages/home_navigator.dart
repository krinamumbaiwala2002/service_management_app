import 'package:flutter/material.dart';
import 'package:service_management_app/main.dart';
import 'home.dart';
import 'service_providers_page.dart';
import 'provider_details_page.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  Key? get homeNavigatorKey => null;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: homeNavigatorKey,
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => const Home());

          case '/providers':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ServiceProvidersPage(
                serviceName: args['serviceName'] as String,
                userId: args['userId'] as String,
              ),
            );

          case '/providerDetail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ProviderDetailPage(
                provider: args['provider'], serviceName: '', userId: '',
              ),
            );
        }
        return null;
      },
    );
  }
}
