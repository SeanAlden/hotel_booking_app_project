// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hotel_booking_app/model/location.dart';
// import 'package:hotel_booking_app/pages/location_detail_page.dart'; // Ganti dengan path yang sesuai

// class LocationSearchPage extends StatefulWidget {
//   const LocationSearchPage({Key? key}) : super(key: key);

//   @override
//   State<LocationSearchPage> createState() => _LocationSearchPageState();
// }

// class _LocationSearchPageState extends State<LocationSearchPage> {
//   List<Location> locations = []; // List untuk menyimpan data lokasi

//   @override
//   void initState() {
//     super.initState();
//     _fetchLocations(); // Ambil data lokasi saat halaman diinisialisasi
//   }

//   Future<void> _fetchLocations() async {
//     final snapshot =
//         await FirebaseFirestore.instance.collection('locations').get();
//     setState(() {
//       locations = snapshot.docs.map((doc) {
//         return Location(
//           id: doc.id,
//           name: doc['name'],
//         );
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Search Location',
//             style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           tooltip: 'Back',
//         ),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 600),
//           child: ListView.separated(
//             itemCount: locations.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(
//                   locations[index].name,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LocationDetailPage(
//                         locationId: locations[index].id,
//                       ),
//                     ),
//                   );
//                 },
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16.0, vertical: 12.0),
//               );
//             },
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//     );
//   }
// }

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
  List<Location> locations = []; // List untuk menyimpan semua data lokasi
  List<Location> filteredLocations = []; // List untuk menyimpan data lokasi yang difilter
  TextEditingController searchController = TextEditingController(); // Controller untuk search bar

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Ambil data lokasi saat halaman diinisialisasi
    searchController.addListener(_filterLocations); // Tambahkan listener ke search controller
  }

  @override
  void dispose() {
    searchController.dispose(); // Pastikan controller di-dispose
    super.dispose();
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
      filteredLocations = locations; // Inisialisasi filteredLocations dengan semua lokasi
    });
  }

  void _filterLocations() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredLocations = locations.where((location) {
        return location.name.toLowerCase().contains(query);
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by location name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredLocations.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        filteredLocations[index].name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationDetailPage(
                              locationId: filteredLocations[index].id,
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
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}