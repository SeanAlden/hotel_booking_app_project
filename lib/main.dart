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
import 'package:hotel_booking_app/pages/get_started_screen.dart';

const String NOTIFICATION_COUNT_BOX = 'notification_count_box';
const String NEW_NOTIFICATION_KEY = 'new_notification_count';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Menangani pesan di latar belakang: ${message.messageId}");

  try {
    if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
      await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
      debugPrint('FCM Latar Belakang: Membuka NOTIFICATION_COUNT_BOX.');
    }
    final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
    int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
    await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
    debugPrint(
        'FCM Latar Belakang: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');

    _showLocalNotification(
      message.notification?.title ?? 'Pesan Latar Belakang Baru',
      message.notification?.body ??
          'Anda memiliki notifikasi baru dari aplikasi.',
      payload: message.data['payload'],
    );
  } catch (e) {
    debugPrint(
        'FCM Latar Belakang: Error saat menambah jumlah notifikasi atau menampilkan notifikasi lokal: $e');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void _showLocalNotification(String title, String body,
    {String? payload}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'booking_channel_id',
    'Booking Notifications',
    channelDescription:
        'Notifikasi untuk pembaruan dan pengingat pemesanan hotel.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    icon: '@mipmap/ic_launcher',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
  debugPrint('Notifikasi lokal ditampilkan: $title - $body');
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  await Hive.openBox<Uint8List>('hotel_images');
  await Hive.openBox<Uint8List>('room_images');
  await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
  await Hive.openBox<bool>('app_settings');
  debugPrint('Kotak Hive diinisialisasi dan dibuka.');

  await initializeDateFormatting('id_ID', null);

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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    debugPrint('Notifikasi lokal diketuk! Payload: ${response.payload}');

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  });

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
        if (!Hive.isBoxOpen(NOTIFICATION_COUNT_BOX)) {
          await Hive.openBox<int>(NOTIFICATION_COUNT_BOX);
          debugPrint('FCM Foreground: Membuka NOTIFICATION_COUNT_BOX.');
        }
        final Box<int> countBox = Hive.box<int>(NOTIFICATION_COUNT_BOX);
        int currentCount = countBox.get(NEW_NOTIFICATION_KEY, defaultValue: 0)!;
        await countBox.put(NEW_NOTIFICATION_KEY, currentCount + 1);
        debugPrint(
            'FCM Foreground: Jumlah notifikasi baru bertambah menjadi: ${currentCount + 1}');
      } catch (e) {
        debugPrint('FCM Foreground: Error saat menambah jumlah notifikasi: $e');
      }
    }
  });

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint(
        'Aplikasi dibuka dari keadaan terminated oleh notifikasi: ${initialMessage.messageId}');
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint(
        'Aplikasi dibuka dari background oleh notifikasi: ${message.messageId}');

    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => const NotificationPage()),
    );
  });

  final Box<bool> appSettingsBox = Hive.box<bool>('app_settings');

  final bool firstLaunchDone =
      appSettingsBox.get(GetStartedScreen.firstLaunchKey, defaultValue: false)!;

  runApp(MyApp(
      initialRoute:
          firstLaunchDone ? const CheckAuth() : const GetStartedScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Aplikasi Pemesanan Hotel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: initialRoute,
    );
  }
}
