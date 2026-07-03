import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raminups/features/home/presentation/screen/home_screen.dart';

import '../../features/auth/presentation/screen/getstart_screen.dart';
import '../constants/app_constants.dart';


CustomTransitionPage<dynamic> buildSlideTransitionPage({
  required LocalKey key,
  required Widget child,
  Offset begin = const Offset(1.0, 0.0),
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
        ) {
      final tween = Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).chain(
        CurveTween(curve: Curves.easeInOut),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}


final initialRouteProvider = Provider<String>((ref) => AppPaths.splash);

final appRouterProvider = Provider<GoRouter>((ref) {
  final initialRoute = ref.watch(initialRouteProvider);
  return GoRouter(
    initialLocation: initialRoute,
    routes: [

      GoRoute(
        path: AppPaths.splash,
        name: AppRoutes.splash,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: GetstartScreen(),
        )
      ),


      GoRoute(
        path: AppPaths.home,
        name: AppRoutes.home,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: HomeScreen(),
        ),
      ),

      // GoRoute(
      //   path: AppPaths.block_userlist,
      //   name: AppRoutes.block_userlist,
      //   pageBuilder: (context, state) => buildSlideTransitionPage(
      //     key: state.pageKey,
      //     child: const BlockedUsersScreen(),
      //   ),
      // ),
      //
      // GoRoute(
      //   path: AppPaths.email_setting,
      //   name: AppRoutes.email_setting,
      //   pageBuilder: (context, state) => buildSlideTransitionPage(
      //     key: state.pageKey,
      //     child: EmailSettingsScreen(),
      //   ),
      // ),
      //
      // GoRoute(
      //   path: AppPaths.security_privacy,
      //   name: AppRoutes.security_privacy,
      //   pageBuilder: (context, state) => buildSlideTransitionPage(
      //     key: state.pageKey,
      //     child: SecurityPrivacyScreen(),
      //   ),
      // ),
      //
      // GoRoute(
      //   path: AppPaths.edit_profile,
      //   name: AppRoutes.edit_profile,
      //   pageBuilder: (context, state) => buildSlideTransitionPage(
      //     key: state.pageKey,
      //     child: EditProfileScreen(),
      //   ),
      // ),
      //
      // GoRoute(
      //   path: AppPaths.chat,
      //   name: AppRoutes.chat,
      //   pageBuilder: (context, state) => buildSlideTransitionPage(
      //     key: state.pageKey,
      //     child: DirectChatScreen(),
      //   ),
      // ),


      // GoRoute(
      //   path: '/communities',
      //   builder: (context, state) => const CommunityListScreen(),
      // ),
      // GoRoute(
      //   path: '/chat/:chatId',
      //   builder: (context, state) {
      //     final chatId = state.pathParameters['chatId']!;
      //     return ChatRoomScreen(chatId: chatId);
      //   },
      // ),
      // GoRoute(
      //   path: '/profile',
      //   builder: (context, state) => const ProfileScreen(),
      // ),

    ],
  );
});