import 'package:flutter/material.dart';
import 'package:trash_map/screens/loading.dart';
import 'package:provider/provider.dart';

import 'models/app_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(
          create: (_) => AppData(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trash Map',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 15, 111, 18),
              primary: const Color.fromARGB(255, 15, 111, 18),
              secondary: Colors.black),
        ),
        home: const Scaffold(
          body: SafeArea(
            child: LoadingPage(),
          ),
        ),
      ),
    );
  }
}
