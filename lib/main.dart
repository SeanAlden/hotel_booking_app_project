// import 'dart:typed_data';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:hotel_booking_app/services/check_auth.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'services/firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Hive.initFlutter(); // Inisialisasi Hive
//   await Hive.openBox<Uint8List>(
//       'hotel_images'); // Buka kotak untuk menyimpan byte gambar
//   await Hive.openBox<Uint8List>(
//       'room_images'); // Buka kotak untuk menyimpan byte gambar
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await initializeDateFormatting(
//       'id_ID', null); // Inisialisasi lokal bahasa Indonesia
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: "Hotel Booking App",
//       debugShowCheckedModeBanner: false,
//       home: CheckAuth(), // Ini akan redirect ke HomePage jika sudah login
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/firebase_options.dart'; // Make sure this file exists
// import 'package:hotel_booking_app/pages/login_page.dart';
// import 'package:hotel_booking_app/model/user.dart'; // Import AppUser
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Top-level function to handle background messages
// // Must not be an anonymous function
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("Handling a background message: ${message.messageId}");
//   // You can show a local notification here even in the background
//   // For example:
//   // _showLocalNotification(
//   //   message.notification?.title ?? 'Background Message',
//   //   message.notification?.body ?? 'You have a new message from the app.',
//   // );
// }

// // Global instance for FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// // Helper to show local notifications
// void _showLocalNotification(String title, String body, {String? payload}) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'booking_channel_id', // ID of the channel
//     'Booking Notifications', // Name of the channel
//     channelDescription: 'Notifications for hotel booking updates and reminders.',
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: false,
//     icon: '@mipmap/ic_launcher', // Ensure you have this icon in android/app/src/main/res/mipmap/
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: payload,
//   );
//   debugPrint('Local notification shown: $title - $body');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize Hive
//   await Hive.initFlutter();
//   // Open your Hive boxes
//   await Hive.openBox<Uint8List>('hotel_images');
//   await Hive.openBox<Uint8List>('room_images');

//   // Request FCM permissions
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('User granted permission: ${settings.authorizationStatus}');

//   // Configure background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Initialize flutter_local_notifications plugin
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     // Handle tap on local notification when app is in foreground/background
//     debugPrint('Local notification tapped! Payload: ${response.payload}');
//     // You can navigate to a specific page based on payload
//     // Example: if (response.payload == 'booking_reminder') { navigateToBookingPage(); }
//   });

//   // Get FCM token and save to Firestore
//   // This should ideally be done when a user logs in or registers
//   // and updated periodically, or when the token refreshes.
//   // For demonstration, we'll do it on app start if a user is already logged in.
//   FirebaseAuth.instance.authStateChanges().listen((user) async {
//     if (user != null) {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('FCM Token: $fcmToken');
//         // Save FCM token to user's Firestore document
//         AppUser? currentUser = await AppUser.fetchUserById(user.uid);
//         if (currentUser != null && currentUser.fcmToken != fcmToken) {
//           await currentUser.updateFcmToken(fcmToken);
//         } else if (currentUser == null) {
//           // This case might happen if user document is not yet created
//           // for a newly logged-in user. You might need to handle user
//           // creation/profile update logic here.
//           debugPrint('User document not found for ${user.uid}. Cannot save FCM token.');
//         }
//       }
//     }
//   });

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     debugPrint('Got a message whilst in the foreground!');
//     debugPrint('Message data: ${message.data}');

//     if (message.notification != null) {
//       debugPrint('Message also contained a notification: ${message.notification}');
//       _showLocalNotification(
//         message.notification?.title ?? 'Notifikasi Baru',
//         message.notification?.body ?? 'Anda memiliki notifikasi baru.',
//         payload: message.data['payload'], // Pass data to payload
//       );
//     }
//   });

//   // Handle messages when app is opened from a terminated state
//   // Check if app was opened by tapping a notification
//   RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     debugPrint('App opened from terminated state by notification: ${initialMessage.messageId}');
//     // You can navigate here based on initialMessage.data
//     // Navigator.pushNamed(context, '/notification_page'); // Example navigation
//   }

//   // Handle messages when app is opened from background state
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint('App opened from background by notification: ${message.messageId}');
//     // Navigate to notification page or relevant screen
//     // You might want to pass data from message.data to the destination page
//     Navigator.push(
//       // Ensure you have a NavigatorState available if using a global key,
//       // or pass context from a higher-level widget.
//       // For simplicity here, assume context is available or use a global key for Navigator.
//       // A more robust solution involves a routing package (e.g., go_router, auto_route).
//       // For this example, we will navigate to NotificationPage.
//       BuildContext context = navigatorKey.currentState!.context;// Requires a GlobalKey<NavigatorState>
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // To make Navigator.push work globally, you might need a GlobalKey
//   runApp(MyApp());
// }

// // Define a GlobalKey for NavigatorState if you need to navigate from outside a widget tree
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey, // Assign the global key
//       title: 'Hotel Booking App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/pages/login_page.dart';
// import 'package:hotel_booking_app/model/user.dart'; // Import AppUser
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:hotel_booking_app/services/firebase_options.dart';
// import 'package:intl/date_symbol_data_local.dart'; // Ensure NotificationPage is imported

// // Top-level function to handle background messages
// // Must not be an anonymous function
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("Handling a background message: ${message.messageId}");
//   // You can show a local notification here even in the background
//   // For example:
//   // _showLocalNotification(
//   //   message.notification?.title ?? 'Background Message',
//   //   message.notification?.body ?? 'You have a new message from the app.',
//   // );
// }

// // Global instance for FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// // Helper to show local notifications
// void _showLocalNotification(String title, String body,
//     {String? payload}) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'booking_channel_id', // ID of the channel
//     'Booking Notifications', // Name of the channel
//     channelDescription:
//         'Notifications for hotel booking updates and reminders.',
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: false,
//     icon:
//         '@mipmap/ic_launcher', // Ensure you have this icon in android/app/src/main/res/mipmap/
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: payload,
//   );
//   debugPrint('Local notification shown: $title - $body');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize Hive
//   await Hive.initFlutter();
//   // Open your Hive boxes
//   await Hive.openBox<Uint8List>('hotel_images');
//   await Hive.openBox<Uint8List>('room_images');

//   // Request FCM permissions
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('User granted permission: ${settings.authorizationStatus}');

//   // Configure background message handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Initialize flutter_local_notifications plugin
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     // Handle tap on local notification when app is in foreground/background
//     debugPrint('Local notification tapped! Payload: ${response.payload}');
//     // You can navigate to a specific page based on payload
//     // This is called when app is in foreground or background and user taps notification.
//     // If you need to navigate, use navigatorKey.currentState?.push or a routing package.
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // Get FCM token and save to Firestore
//   FirebaseAuth.instance.authStateChanges().listen((user) async {
//     if (user != null) {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('FCM Token: $fcmToken');
//         AppUser? currentUser = await AppUser.fetchUserById(user.uid);
//         if (currentUser != null && currentUser.fcmToken != fcmToken) {
//           await currentUser.updateFcmToken(fcmToken);
//         } else if (currentUser == null) {
//           debugPrint(
//               'User document not found for ${user.uid}. Cannot save FCM token.');
//         }
//       }
//     }
//   });

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     debugPrint('Got a message whilst in the foreground!');
//     debugPrint('Message data: ${message.data}');

//     if (message.notification != null) {
//       debugPrint(
//           'Message also contained a notification: ${message.notification}');
//       _showLocalNotification(
//         message.notification?.title ?? 'Notifikasi Baru',
//         message.notification?.body ?? 'Anda memiliki notifikasi baru.',
//         payload: message.data['payload'],
//       );
//     }
//   });

//   // Handle messages when app is opened from a terminated state
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     debugPrint(
//         'App opened from terminated state by notification: ${initialMessage.messageId}');
//     // You can navigate here based on initialMessage.data, e.g., using navigatorKey.currentState?.push
//     // We defer navigation to the main app's build method or a post-startup callback
//     // to ensure the widget tree is fully built.
//   }

//   // Handle messages when app is opened from background state
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint(
//         'App opened from background by notification: ${message.messageId}');
//     // Correct way to navigate using GlobalKey
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });
//   await initializeDateFormatting(
//       'id_ID', null); // Inisialisasi lokal bahasa Indonesia
//   runApp(const MyApp());
// }

// // Define a GlobalKey for NavigatorState if you need to navigate from outside a widget tree
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key}); // Make constructor const

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey, // Assign the global key
//       title: 'Hotel Booking App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/pages/login_page.dart';
// import 'package:hotel_booking_app/model/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:hotel_booking_app/services/firebase_options.dart';
// import 'package:intl/date_symbol_data_local.dart'; // Ensure NotificationPage is imported

// // Name of the Hive box to store notification count
// const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
// const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// // Top-level function to handle background messages
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("Handling a background message: ${message.messageId}");

//   // Increment notification count in Hive for background messages
//   final Box<int> countBox = await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//   int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//   await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//   debugPrint('Background FCM: New notification count: ${currentCount + 1}');

//   _showLocalNotification(
//     message.notification?.title ?? 'Pesan Latar Belakang Baru',
//     message.notification?.body ??
//         'Anda memiliki notifikasi baru dari aplikasi.',
//     payload: message.data['payload'],
//   );
// }

// // Global instance for FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// // Helper to show local notifications
// void _showLocalNotification(String title, String body,
//     {String? payload}) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'booking_channel_id',
//     'Booking Notifications',
//     channelDescription:
//         'Notifications for hotel booking updates and reminders.',
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: false,
//     icon: '@mipmap/ic_launcher',
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: payload,
//   );
//   debugPrint('Local notification shown: $title - $body');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize Hive and open required boxes
//   await Hive.initFlutter();
//   await Hive.openBox<Uint8List>('hotel_images');
//   await Hive.openBox<Uint8List>('room_images');
//   await Hive.openBox<int>(
//       NOTIFICATION_COUNT_BOX); // Open box for notification count

//   await initializeDateFormatting(
//       'id_ID', null); // Inisialisasi lokal bahasa Indonesia

//   // Request FCM permissions
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('User granted permission: ${settings.authorizationStatus}');

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     debugPrint('Local notification tapped! Payload: ${response.payload}');
//     // Navigate to NotificationPage when notification is tapped
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // Get FCM token and save to Firestore
//   FirebaseAuth.instance.authStateChanges().listen((user) async {
//     if (user != null) {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('FCM Token: $fcmToken');
//         AppUser? currentUser = await AppUser.fetchUserById(user.uid);
//         if (currentUser != null && currentUser.fcmToken != fcmToken) {
//           await currentUser.updateFcmToken(fcmToken);
//         } else if (currentUser == null) {
//           debugPrint(
//               'User document not found for ${user.uid}. Cannot save FCM token.');
//         }
//       }
//     }
//   });

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     debugPrint('Got a message whilst in the foreground!');
//     debugPrint('Message data: ${message.data}');

//     if (message.notification != null) {
//       _showLocalNotification(
//         message.notification?.title ?? 'Notifikasi Baru',
//         message.notification?.body ?? 'Anda memiliki notifikasi baru.',
//         payload: message.data['payload'],
//       );

//       // Increment notification count in Hive for foreground messages
//       final Box<int> countBox = await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//       int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//       await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//       debugPrint('Foreground FCM: New notification count: ${currentCount + 1}');
//     }
//   });

//   // Handle messages when app is opened from a terminated state
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     debugPrint(
//         'App opened from terminated state by notification: ${initialMessage.messageId}');
//     // No need to increment count here, as the user is directly navigating.
//     // The NotificationPage will reset the count upon loading.
//   }

//   // Handle messages when app is opened from background state
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint(
//         'App opened from background by notification: ${message.messageId}');
//     // No need to increment count here, as the user is directly navigating.
//     // The NotificationPage will reset the count upon loading.
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   runApp(const MyApp());
// }

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Hotel Booking App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/pages/login_page.dart';
// import 'package:hotel_booking_app/model/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:hotel_booking_app/services/firebase_options.dart';
// import 'package:intl/date_symbol_data_local.dart';

// // Name of the Hive box to store notification count
// const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
// const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// // Top-level function to handle background messages
// @pragma('vm:entry-point') // Required for background message handler on Android
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("Handling a background message: ${message.messageId}");

//   try {
//     // Ensure the box is open before incrementing
//     if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
//       await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//       debugPrint('Background FCM: Opened NOTIFICATION_COUNT_BOX.');
//     }
//     final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//     int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//     await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//     debugPrint('Background FCM: New notification count incremented to: ${currentCount + 1}');

//     _showLocalNotification(
//       message.notification?.title ?? 'Pesan Latar Belakang Baru',
//       message.notification?.body ??
//           'Anda memiliki notifikasi baru dari aplikasi.',
//       payload: message.data['payload'],
//     );
//   } catch (e) {
//     debugPrint('Background FCM: Error incrementing notification count or showing local notification: $e');
//   }
// }

// // Global instance for FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// // Helper to show local notifications
// void _showLocalNotification(String title, String body,
//     {String? payload}) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'booking_channel_id',
//     'Booking Notifications',
//     channelDescription:
//         'Notifications for hotel booking updates and reminders.',
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: false,
//     icon: '@mipmap/ic_launcher',
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0, // Notification ID
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: payload,
//   );
//   debugPrint('Local notification shown: $title - $body');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Initialize Hive and open required boxes
//   await Hive.initFlutter();
//   await Hive.openBox<Uint8List>('hotel_images');
//   await Hive.openBox<Uint8List>('room_images');
//   await Hive.openBox<int>(NOTIFICATION_COUNT_BOX); // Open box for notification count
//   debugPrint('Hive boxes initialized and opened.');

//   await initializeDateFormatting(
//       'id_ID', null); // Inisialisasi lokal bahasa Indonesia

//   // Request FCM permissions
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('User granted permission: ${settings.authorizationStatus}');

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     debugPrint('Local notification tapped! Payload: ${response.payload}');
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // Get FCM token and save to Firestore
//   FirebaseAuth.instance.authStateChanges().listen((user) async {
//     if (user != null) {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('FCM Token: $fcmToken');
//         AppUser? currentUser = await AppUser.fetchUserById(user.uid);
//         if (currentUser != null && currentUser.fcmToken != fcmToken) {
//           await currentUser.updateFcmToken(fcmToken);
//         } else if (currentUser == null) {
//           debugPrint(
//               'User document not found for ${user.uid}. Cannot save FCM token.');
//         }
//       }
//     }
//   });

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     debugPrint('Got a message whilst in the foreground!');
//     debugPrint('Message data: ${message.data}');

//     if (message.notification != null) {
//       _showLocalNotification(
//         message.notification?.title ?? 'Notifikasi Baru',
//         message.notification?.body ?? 'Anda memiliki notifikasi baru.',
//         payload: message.data['payload'],
//       );

//       try {
//         // Ensure the box is open before incrementing
//         if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
//           await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//           debugPrint('Foreground FCM: Opened NOTIFICATION_COUNT_BOX.');
//         }
//         final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//         int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//         await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//         debugPrint('Foreground FCM: New notification count incremented to: ${currentCount + 1}');
//       } catch (e) {
//         debugPrint('Foreground FCM: Error incrementing notification count: $e');
//       }
//     }
//   });

//   // Handle messages when app is opened from a terminated state
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     debugPrint(
//         'App opened from terminated state by notification: ${initialMessage.messageId}');
//     // The NotificationPage will reset the count upon loading, so no need to increment here.
//   }

//   // Handle messages when app is opened from background state
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint(
//         'App opened from background by notification: ${message.messageId}');
//     // The NotificationPage will reset the count upon loading, so no need to increment here.
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   runApp(const MyApp());
// }

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Hotel Booking App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginPage(),
//     );
//   }
// }

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/model/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:hotel_booking_app/services/check_auth.dart';
// import 'package:hotel_booking_app/services/firebase_options.dart';
// import 'package:intl/date_symbol_data_local.dart';

// // Nama kotak Hive untuk menyimpan jumlah notifikasi
// const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
// const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// // Fungsi top-level untuk menangani pesan di latar belakang
// // Harus dianotasi dengan @pragma('vm:entry-point') untuk Android
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("Menangani pesan di latar belakang: ${message.messageId}");

//   try {
//     // Pastikan kotak Hive terbuka dalam konteks latar belakang
//     if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
//       await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//       debugPrint('FCM Latar Belakang: Membuka NOTIFICATION_COUNT_BOX.');
//     }
//     final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//     int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//     await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//     debugPrint('FCM Latar Belakang: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');

//     _showLocalNotification(
//       message.notification?.title ?? 'Pesan Latar Belakang Baru',
//       message.notification?.body ??
//           'Anda memiliki notifikasi baru dari aplikasi.',
//       payload: message.data['payload'],
//     );
//   } catch (e) {
//     debugPrint('FCM Latar Belakang: Error saat menambah jumlah notifikasi atau menampilkan notifikasi lokal: $e');
//   }
// }

// // Instansi global untuk FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// // Helper untuk menampilkan notifikasi lokal
// void _showLocalNotification(String title, String body,
//     {String? payload}) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'booking_channel_id', // ID saluran
//     'Booking Notifications', // Nama saluran
//     channelDescription:
//         'Notifikasi untuk pembaruan dan pengingat pemesanan hotel.',
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: false,
//     icon: '@mipmap/ic_launcher', // Pastikan Anda memiliki ikon ini di android/app/src/main/res/mipmap/
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0, // ID Notifikasi
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: payload,
//   );
//   debugPrint('Notifikasi lokal ditampilkan: $title - $body');
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Inisialisasi Hive dan buka kotak yang diperlukan
//   await Hive.initFlutter();
//   await Hive.openBox<Uint8List>('hotel_images');
//   await Hive.openBox<Uint8List>('room_images');
//   await Hive.openBox<int>(NOTIFICATION_COUNT_BOX); // Buka kotak untuk jumlah notifikasi
//   debugPrint('Kotak Hive diinisialisasi dan dibuka.');

//   await initializeDateFormatting('id_ID', null); // Inisialisasi lokal bahasa Indonesia untuk intl

//   // Minta izin FCM
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('Pengguna memberikan izin: ${settings.authorizationStatus}');

//   // Konfigurasi handler pesan latar belakang
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Inisialisasi plugin flutter_local_notifications
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher'); // Ikon aplikasi
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     debugPrint('Notifikasi lokal diketuk! Payload: ${response.payload}');
//     // Navigasi ke NotificationPage saat notifikasi diketuk
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // Dapatkan token FCM dan simpan ke Firestore
//   FirebaseAuth.instance.authStateChanges().listen((user) async {
//     if (user != null) {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('Token FCM: $fcmToken');
//         AppUser? currentUser = await AppUser.fetchUserById(user.uid);
//         if (currentUser != null && currentUser.fcmToken != fcmToken) {
//           await currentUser.updateFcmToken(fcmToken);
//         } else if (currentUser == null) {
//           debugPrint(
//               'Dokumen pengguna tidak ditemukan untuk ${user.uid}. Tidak dapat menyimpan token FCM.');
//         }
//       }
//     }
//   });

//   // Tangani pesan saat aplikasi di foreground
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     debugPrint('Mendapat pesan saat di foreground!');
//     debugPrint('Data pesan: ${message.data}');

//     if (message.notification != null) {
//       _showLocalNotification(
//         message.notification?.title ?? 'Notifikasi Baru',
//         message.notification?.body ?? 'Anda memiliki notifikasi baru.',
//         payload: message.data['payload'],
//       );

//       try {
//         // Pastikan kotak Hive terbuka sebelum menambah
//         if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
//           await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//           debugPrint('FCM Foreground: Membuka NOTIFICATION_COUNT_BOX.');
//         }
//         final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//         int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//         await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//         debugPrint('FCM Foreground: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');
//       } catch (e) {
//         debugPrint('FCM Foreground: Error saat menambah jumlah notifikasi: $e');
//       }
//     }
//   });

//   // Tangani pesan saat aplikasi dibuka dari keadaan terminated
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     debugPrint(
//         'Aplikasi dibuka dari keadaan terminated oleh notifikasi: ${initialMessage.messageId}');
//     // Hitungan TIDAK diinkremen di sini, karena pengguna langsung menavigasi.
//     // initState NotificationPage akan mereset hitungan saat memuat.
//   }

//   // Tangani pesan saat aplikasi dibuka dari keadaan background
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint(
//         'Aplikasi dibuka dari background oleh notifikasi: ${message.messageId}');
//     // Hitungan TIDAK diinkremen di sini, karena pengguna langsung menavigasi.
//     // initState NotificationPage akan mereset hitungan saat memuat.
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   runApp(const MyApp());
// }

// // GlobalKey untuk NavigatorState jika Anda perlu menavigasi dari luar widget tree
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       navigatorKey: navigatorKey, // Tetapkan kunci global
//       title: 'Aplikasi Pemesanan Hotel',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       // home: const LoginPage(),
//       home: CheckAuth(),
//     );
//   }
// }

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hotel_booking_app/model/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hotel_booking_app/pages/notification_page.dart';
// import 'package:hotel_booking_app/services/check_auth.dart';
// import 'package:hotel_booking_app/services/firebase_options.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:hotel_booking_app/pages/get_started_screen.dart'; // Import GetStartedScreen

// // Nama kotak Hive untuk menyimpan jumlah notifikasi
// const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
// const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// // Fungsi top-level untuk menangani pesan di latar belakang
// // Harus dianotasi dengan @pragma('vm:entry-point') untuk Android
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint("Menangani pesan di latar belakang: ${message.messageId}");

//   try {
//     // Pastikan kotak Hive terbuka dalam konteks latar belakang
//     if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
//       await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//       debugPrint('FCM Latar Belakang: Membuka NOTIFICATION_COUNT_BOX.');
//     }
//     final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//     int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//     await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//     debugPrint('FCM Latar Belakang: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');

//     _showLocalNotification(
//       message.notification?.title ?? 'Pesan Latar Belakang Baru',
//       message.notification?.body ??
//           'Anda memiliki notifikasi baru dari aplikasi.',
//       payload: message.data['payload'],
//     );
//   } catch (e) {
//     debugPrint('FCM Latar Belakang: Error saat menambah jumlah notifikasi atau menampilkan notifikasi lokal: $e');
//   }
// }

// // Instansi global untuk FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// // Helper untuk menampilkan notifikasi lokal
// void _showLocalNotification(String title, String body,
//     {String? payload}) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//     'booking_channel_id', // ID saluran
//     'Booking Notifications', // Nama saluran
//     channelDescription:
//         'Notifikasi untuk pembaruan dan pengingat pemesanan hotel.',
//     importance: Importance.max,
//     priority: Priority.high,
//     showWhen: false,
//     icon: '@mipmap/ic_launcher', // Pastikan Anda memiliki ikon ini di android/app/src/main/res/mipmap/
//   );
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0, // ID Notifikasi
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: payload,
//   );
//   debugPrint('Notifikasi lokal ditampilkan: $title - $body');
// }

// // GlobalKey untuk NavigatorState jika Anda perlu menavigasi dari luar widget tree
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // Inisialisasi Hive dan buka kotak yang diperlukan
//   await Hive.initFlutter();
//   await Hive.openBox<Uint8List>('hotel_images');
//   await Hive.openBox<Uint8List>('room_images');
//   await Hive.openBox<int>(NOTIFICATION_COUNT_BOX); // Buka kotak untuk jumlah notifikasi
//   await Hive.openBox<bool>('app_settings'); // Buka kotak untuk pengaturan aplikasi, termasuk status first launch
//   debugPrint('Kotak Hive diinisialisasi dan dibuka.');

//   await initializeDateFormatting('id_ID', null); // Inisialisasi lokal bahasa Indonesia untuk intl

//   // Minta izin FCM
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   debugPrint('Pengguna memberikan izin: ${settings.authorizationStatus}');

//   // Konfigurasi handler pesan latar belakang
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // Inisialisasi plugin flutter_local_notifications
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher'); // Ikon aplikasi
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//     debugPrint('Notifikasi lokal diketuk! Payload: ${response.payload}');
//     // Navigasi ke NotificationPage saat notifikasi diketuk
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // Dapatkan token FCM dan simpan ke Firestore
//   FirebaseAuth.instance.authStateChanges().listen((user) async {
//     if (user != null) {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('Token FCM: $fcmToken');
//         AppUser? currentUser = await AppUser.fetchUserById(user.uid);
//         if (currentUser != null && currentUser.fcmToken != fcmToken) {
//           await currentUser.updateFcmToken(fcmToken);
//         } else if (currentUser == null) {
//           debugPrint(
//               'Dokumen pengguna tidak ditemukan untuk ${user.uid}. Tidak dapat menyimpan token FCM.');
//         }
//       }
//     }
//   });

//   // Tangani pesan saat aplikasi di foreground
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     debugPrint('Mendapat pesan saat di foreground!');
//     debugPrint('Data pesan: ${message.data}');

//     if (message.notification != null) {
//       _showLocalNotification(
//         message.notification?.title ?? 'Notifikasi Baru',
//         message.notification?.body ?? 'Anda memiliki notifikasi baru.',
//         payload: message.data['payload'],
//       );

//       try {
//         // Pastikan kotak Hive terbuka sebelum menambah
//         if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
//           await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
//           debugPrint('FCM Foreground: Membuka NOTIFICATION_COUNT_BOX.');
//         }
//         final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
//         int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
//         await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
//         debugPrint('FCM Foreground: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');
//       } catch (e) {
//         debugPrint('FCM Foreground: Error saat menambah jumlah notifikasi: $e');
//       }
//     }
//   });

//   // Tangani pesan saat aplikasi dibuka dari keadaan terminated
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     debugPrint(
//         'Aplikasi dibuka dari keadaan terminated oleh notifikasi: ${initialMessage.messageId}');
//     // Hitungan TIDAK diinkremen di sini, karena pengguna langsung menavigasi.
//     // initState NotificationPage akan mereset hitungan saat memuat.
//   }

//   // Tangani pesan saat aplikasi dibuka dari keadaan background
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     debugPrint(
//         'Aplikasi dibuka dari background oleh notifikasi: ${message.messageId}');
//     // Hitungan TIDAK diinkremen di sini, karena pengguna langsung menavigasi.
//     // initState NotificationPage akan mereset hitungan saat memuat.
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const NotificationPage()),
//     );
//   });

//   // Tentukan halaman awal berdasarkan status pertama kali buka aplikasi
//   final Box<bool> appSettingsBox = Hive.box<bool>('app_settings');
//   final bool firstLaunchDone = appSettingsBox.get(GetStartedScreen.firstLaunchKey, defaultValue: false)!;

//   runApp(MyApp(initialRoute: firstLaunchDone ? const CheckAuth() : const GetStartedScreen()));
// }

// class MyApp extends StatelessWidget {
//   final Widget initialRoute; // Tambahkan properti untuk rute awal

//   const MyApp({super.key, required this.initialRoute}); // Perbarui konstruktor

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       navigatorKey: navigatorKey, // Tetapkan kunci global
//       title: 'Aplikasi Pemesanan Hotel',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: initialRoute, // Gunakan initialRoute di sini
//     );
//   }
// }

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotel_booking_app/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hotel_booking_app/pages/notification_page.dart';
import 'package:hotel_booking_app/services/check_auth.dart';
import 'package:hotel_booking_app/services/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hotel_booking_app/pages/get_started_screen.dart'; // Import GetStartedScreen

// Nama kotak Hive untuk menyimpan jumlah notifikasi
const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
const String NEW_NOTIFICATION_KEY = 'new_notification_count';

// Fungsi top-level untuk menangani pesan di latar belakang
// Harus dianotasi dengan @pragma('vm:entry-point') untuk Android
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Menangani pesan di latar belakang: ${message.messageId}");

  try {
    // Pastikan kotak Hive terbuka dalam konteks latar belakang
    if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
      await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
      debugPrint('FCM Latar Belakang: Membuka NOTIFICATION_COUNT_BOX.');
    }
    final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
    int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
    await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
    debugPrint('FCM Latar Belakang: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');

    _showLocalNotification(
      message.notification?.title ?? 'Pesan Latar Belakang Baru',
      message.notification?.body ??
          'Anda memiliki notifikasi baru dari aplikasi.',
      payload: message.data['payload'],
    );
  } catch (e) {
    debugPrint('FCM Latar Belakang: Error saat menambah jumlah notifikasi atau menampilkan notifikasi lokal: $e');
  }
}

// Instansi global untuk FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Helper untuk menampilkan notifikasi lokal
void _showLocalNotification(String title, String body,
    {String? payload}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'booking_channel_id', // ID saluran
    'Booking Notifications', // Nama saluran
    channelDescription:
        'Notifikasi untuk pembaruan dan pengingat pemesanan hotel.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    icon: '@mipmap/ic_launcher', // Pastikan Anda memiliki ikon ini di android/app/src/main/res/mipmap/
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0, // ID Notifikasi
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
  debugPrint('Notifikasi lokal ditampilkan: $title - $body');
}

// GlobalKey untuk NavigatorState jika Anda perlu menavigasi dari luar widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi Hive dan buka kotak yang diperlukan
  await Hive.initFlutter();
  await Hive.openBox<Uint8List>('hotel_images');
  await Hive.openBox<Uint8List>('room_images');
  await Hive.openBox<int>(NOTIFICATION_COUNT_BOX); // Buka kotak untuk jumlah notifikasi
  await Hive.openBox<bool>('app_settings'); // Buka kotak untuk pengaturan aplikasi, termasuk status first launch
  debugPrint('Kotak Hive diinisialisasi dan dibuka.');

  await initializeDateFormatting('id_ID', null); // Inisialisasi lokal bahasa Indonesia untuk intl

  // Minta izin FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('Pengguna memberikan izin: ${settings.authorizationStatus}');

  // Konfigurasi handler pesan latar belakang
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inisialisasi plugin flutter_local_notifications
  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    debugPrint('Notifikasi lokal diketuk! Payload: ${response.payload}');
    // Navigasi ke NotificationPage saat notifikasi diketuk
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  });

  // Dapatkan token FCM dan simpan ke Firestore
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        debugPrint('Token FCM: $fcmToken');
        AppUser? currentUser = await AppUser.fetchUserById(user.uid);
        if (currentUser != null && currentUser.fcmToken != fcmToken) {
          await currentUser.updateFcmToken(fcmToken);
        } else if (currentUser == null) {
          debugPrint(
              'Dokumen pengguna tidak ditemukan untuk ${user.uid}. Tidak dapat menyimpan token FCM.');
        }
      }
    }
  });

  // Tangani pesan saat aplikasi di foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    debugPrint('Mendapat pesan saat di foreground!');
    debugPrint('Data pesan: ${message.data}');

    if (message.notification != null) {
      _showLocalNotification(
        message.notification?.title ?? 'Notifikasi Baru',
        message.notification?.body ?? 'Anda memiliki notifikasi baru.',
        payload: message.data['payload'],
      );

      try {
        // Pastikan kotak Hive terbuka sebelum menambah
        if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
          await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
          debugPrint('FCM Foreground: Membuka NOTIFICATION_COUNT_BOX.');
        }
        final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
        int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
        await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
        debugPrint('FCM Foreground: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');
      } catch (e) {
        debugPrint('FCM Foreground: Error saat menambah jumlah notifikasi: $e');
      }
    }
  });

  // Tangani pesan saat aplikasi dibuka dari keadaan terminated
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint(
        'Aplikasi dibuka dari keadaan terminated oleh notifikasi: ${initialMessage.messageId}');
    // Hitungan TIDAK diinkremen di sini, karena pengguna langsung menavigasi.
    // initState NotificationPage akan mereset hitungan saat memuat.
  }

  // Tangani pesan saat aplikasi dibuka dari keadaan background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint(
        'Aplikasi dibuka dari background oleh notifikasi: ${message.messageId}');
    // Hitungan TIDAK diinkremen di sini, karena pengguna langsung menavigasi.
    // initState NotificationPage akan mereset hitungan saat memuat.
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  });

  // Tentukan halaman awal berdasarkan status pertama kali buka aplikasi
  final Box<bool> appSettingsBox = Hive.box<bool>('app_settings');
  // Ubah GetStartedScreen._firstLaunchKey menjadi GetStartedScreen.firstLaunchKey
  final bool firstLaunchDone = appSettingsBox.get(GetStartedScreen.firstLaunchKey, defaultValue: false)!;

  runApp(MyApp(initialRoute: firstLaunchDone ? const CheckAuth() : const GetStartedScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute; // Tambahkan properti untuk rute awal

  const MyApp({super.key, required this.initialRoute}); // Perbarui konstruktor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Tetapkan kunci global
      title: 'Aplikasi Pemesanan Hotel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: initialRoute, // Gunakan initialRoute di sini
    );
  }
}
