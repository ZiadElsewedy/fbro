import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fbro/core/di/injection.dart';
import 'package:fbro/core/routes/app_router.dart';
import 'package:fbro/core/routes/route_names.dart';
import 'package:fbro/core/theme/app_theme.dart';
import 'package:fbro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fbro/features/auth/presentation/cubit/auth_state.dart';
import 'package:fbro/firebase_options.dart';

/// Background FCM handler. The push carries a `notification` block, so the OS
/// renders it while the app is backgrounded/terminated — no background data
/// processing is needed here. Must be a top-level, vm:entry-point function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Lets the notification service surface foreground pushes as in-app snackbars.
final GlobalKey<ScaffoldMessengerState> _messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// The app router, created once so the FCM tap handler can navigate.
late final GoRouter _router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Offline-first: enable Firestore local persistence with an unlimited cache so
  // the app survives unstable connections — cached reads, queued writes that
  // sync on reconnect, and no crashes when the network drops. Mobile enables
  // persistence by default; we set it explicitly (and lift the cache cap) for
  // production. Must run before any Firestore operation.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  AppDependencies.init();
  _router = createRouter(AppDependencies.authCubit);

  // FCM engine (best-effort; never blocks startup).
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AppDependencies.notificationService
    ..onForeground = (title, body) {
      final text = [title, body]
          .where((s) => s != null && s.isNotEmpty)
          .join(' — ');
      if (text.isNotEmpty) {
        _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
      }
    }
    ..onMessageTap = (data) {
      // Notification tapped (from background or cold start). The broadcast
      // detail screen lands in a later phase; for now open the app at the
      // signed-in user's home (the router redirects to the right role shell)
      // and log the payload so the future deep-link has what it needs.
      developer.log(
        'Notification tapped — broadcast=${data['broadcastId']} '
        'category=${data['category']} sender=${data['senderId']}',
        name: 'fcm',
      );
      _router.go(RouteNames.home);
    }
    ..init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: AppDependencies.authCubit),
        BlocProvider.value(value: AppDependencies.profileCubit),
        BlocProvider.value(value: AppDependencies.taskCubit),
        BlocProvider.value(value: AppDependencies.branchCubit),
        BlocProvider.value(value: AppDependencies.adminUsersCubit),
        BlocProvider.value(value: AppDependencies.statisticsCubit),
        BlocProvider.value(value: AppDependencies.scheduleCubit),
        BlocProvider.value(value: AppDependencies.shiftSwapCubit),
        BlocProvider.value(value: AppDependencies.branchOperationsCubit),
        BlocProvider.value(value: AppDependencies.broadcastCubit),
      ],
      // Register / clear the FCM token as the auth session changes.
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (u) {
              AppDependencies.notificationService.registerToken(u.uid);
            },
            unauthenticated: () {
              AppDependencies.notificationService.forgetUser();
            },
            orElse: () {},
          );
        },
        child: MaterialApp.router(
          title: 'DROP',
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          scaffoldMessengerKey: _messengerKey,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
