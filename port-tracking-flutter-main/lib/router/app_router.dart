import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/fiches/fiche_list_screen.dart';
import '../screens/fiches/fiche_detail_screen.dart';
import '../screens/fiches/create_fiche_screen.dart';
import '../screens/conteneurs/conteneur_list_screen.dart';
import '../screens/conteneurs/conteneur_detail_screen.dart';
import '../screens/inspections/inspection_list_screen.dart';
import '../screens/inspections/inspection_detail_screen.dart';
import '../screens/notifications/notification_list_screen.dart';
import '../screens/admin/user_management_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginPage = state.matchedLocation == '/login';
      if (!isAuthenticated && !isLoginPage) return '/login';
      if (isAuthenticated && isLoginPage) return '/dashboard';
      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/fiches',
        builder: (context, state) => const FicheListScreen(),
      ),
      GoRoute(
        path: '/fiches/create',
        builder: (context, state) => const CreateFicheScreen(),
      ),
      GoRoute(
        path: '/fiches/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return FicheDetailScreen(ficheId: id);
        },
      ),
      GoRoute(
        path: '/conteneurs',
        builder: (context, state) => const ConteneurListScreen(),
      ),
      GoRoute(
        path: '/conteneurs/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ConteneurDetailScreen(conteneurId: id);
        },
      ),
      GoRoute(
        path: '/inspections',
        builder: (context, state) => const InspectionListScreen(),
      ),
      GoRoute(
        path: '/inspections/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return InspectionDetailScreen(inspectionId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationListScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
  );
}