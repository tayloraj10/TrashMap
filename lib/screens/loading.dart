import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/constants.dart';
import 'package:trash_map/screens/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(_controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    Provider.of<AppData>(context, listen: false).resetCounts();
    if (mounted) {
      await Provider.of<AppData>(context, listen: false)
          .loadIcons(context: context, mounted: mounted);
    }
    if (mounted) {
      await Provider.of<AppData>(context, listen: false)
          .loadCleanups(context: context, auth: auth);
    }
    if (mounted) {
      await Provider.of<AppData>(context, listen: false)
          .loadTrash(context: context, auth: auth);
    }
    if (auth.currentUser != null) {
      if (mounted) {
        await Provider.of<AppData>(context, listen: false)
            .loadCleanupRoutes(context: context);
      }
      if (mounted) {
        await Provider.of<AppData>(context, listen: false)
            .loadCleanupPaths(context: context);
      }
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                appName,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: primaryColor),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 150,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            _animation.value,
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 50,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Icon(Icons.delete,
                        size: 150, color: Colors.black.withOpacity(1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
