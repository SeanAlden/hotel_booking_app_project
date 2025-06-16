import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/location_detail_page.dart'; // Ganti dengan path yang sesuai

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({Key? key}) : super(key: key);

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  List<Location> locations = []; // List untuk menyimpan data lokasi

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Ambil data lokasi saat halaman diinisialisasi
  }

  Future<void> _fetchLocations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locations').get();
    setState(() {
      locations = snapshot.docs.map((doc) {
        return Location(
          id: doc.id,
          name: doc['name'],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'Back',
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.separated(
            itemCount: locations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  locations[index].name,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailPage(
                        locationId: locations[index].id,
                      ),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              );
            },
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
