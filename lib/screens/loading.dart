import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/marker_dialog.dart';
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
    loadData();
  }

  Future<void> loadData() async {
    await loadIcons();
    await loadCleanups();
    await loadTrash();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(),
        ),
      );
    }
  }

  Future<void> loadIcons() async {
    BitmapDescriptor currentLocationMarkerIcon =
        await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/current-location.png',
    );
    BitmapDescriptor cleanMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/clean.png',
    );
    BitmapDescriptor trashMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/trash.png',
    );
    if (mounted) {
      Provider.of<AppData>(context, listen: false).updateIcons({
        'current': currentLocationMarkerIcon,
        'cleanup': cleanMarkerIcon,
        'trash': trashMarkerIcon
      });
    }
  }

  loadCleanups() async {
    await FirebaseFirestore.instance
        .collection("cleanups")
        .where('active', isEqualTo: true)
        .get()
        .then((value) => {
              for (var element in value.docs)
                {
                  Provider.of<AppData>(context, listen: false).addMarker(
                    Marker(
                      markerId: MarkerId('cleanup${element.id}'),
                      icon: Provider.of<AppData>(context, listen: false)
                          .getIcons['cleanup'],
                      position:
                          LatLng(element.data()['lat'], element.data()['lng']),
                      onTap: (() => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Return widget tree containing the AlertDialog
                              return MarkerDialog(
                                data: element.data(),
                                id: element.id,
                                type: 'Cleanup',
                              );
                            },
                          )),
                    ),
                  )
                }
            });
  }

  loadTrash() async {
    await FirebaseFirestore.instance
        .collection("trash")
        .where('active', isEqualTo: true)
        .get()
        .then((value) => {
              for (var element in value.docs)
                {
                  Provider.of<AppData>(context, listen: false).addMarker(
                    Marker(
                      markerId: MarkerId('trash${element.id}'),
                      icon: Provider.of<AppData>(context, listen: false)
                          .getIcons['trash'],
                      position:
                          LatLng(element.data()['lat'], element.data()['lng']),
                      onTap: (() => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MarkerDialog(
                                data: element.data(),
                                id: element.id,
                                type: 'Trash Report',
                              );
                            },
                          ).then((value) => hideCleanedTrash(value))),
                    ),
                  )
                }
            });
  }

  hideCleanedTrash(String markerID) {
    Provider.of<AppData>(context, listen: false).removeMarker(markerID);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            appName,
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.w700, color: primaryColor),
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
    );
  }
}
