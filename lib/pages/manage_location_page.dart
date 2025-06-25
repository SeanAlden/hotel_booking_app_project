import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/location.dart';
import 'package:hotel_booking_app/pages/add_location_page.dart';
import 'package:hotel_booking_app/pages/edit_location_page.dart';

class ManageLocationPage extends StatefulWidget {
  const ManageLocationPage({Key? key}) : super(key: key);

  @override
  State<ManageLocationPage> createState() => _ManageLocationPageState();
}

class _ManageLocationPageState extends State<ManageLocationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      debugPrint('ManageLocationPage: Search query changed to: $_searchQuery');
    });
  }

  Future<void> _deleteLocation(String locationId) async {
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Location'),
            content: const Text(
                'Are you sure you want to delete this location? All hotels and rooms associated with this location will also be affected or become orphaned.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        await FirebaseFirestore.instance
            .collection('locations')
            .doc(locationId)
            .delete();
        debugPrint(
            'ManageLocationPage: Location ID $locationId deleted from Firestore.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location deleted successfully!')),
        );
      } catch (e) {
        debugPrint(
            'ManageLocationPage: Error deleting location $locationId: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Locations',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search locations by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('locations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint(
                      'ManageLocationPage: StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No locations added yet.'));
                }

                final allLocations = snapshot.data!.docs;
                final filteredLocations = allLocations.where((locationDoc) {
                  final locationName =
                      (locationDoc.data() as Map<String, dynamic>)['name']
                              ?.toLowerCase() ??
                          '';
                  return locationName.contains(_searchQuery);
                }).toList();

                if (filteredLocations.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                      child: Text(
                          'No locations found matching "${_searchQuery}"'));
                } else if (filteredLocations.isEmpty) {
                  return const Center(child: Text('No locations added yet.'));
                }
                debugPrint(
                    'ManageLocationPage: Displaying ${filteredLocations.length} locations.');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final locationDoc = filteredLocations[index];
                    final location = Location(
                      id: locationDoc.id,
                      name: (locationDoc.data()
                              as Map<String, dynamic>)['name'] ??
                          'Unknown Location',
                    );

                    return _ManageLocationListItem(
                      location: location,
                      onEdit: () async {
                        debugPrint(
                            'Navigating to EditLocationPage for ID: ${location.id}');
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditLocationPage(locationId: location.id),
                          ),
                        );
                        if (result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Location data refreshed!')),
                          );
                        }
                      },
                      onDelete: () => _deleteLocation(location.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLocationPage()),
          );
        },
        label: const Text('Add Location'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ManageLocationListItem extends StatelessWidget {
  final Location location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageLocationListItem({
    Key? key,
    required this.location,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child:
                  const Icon(Icons.location_on, size: 40, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('ID: ${location.id}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Edit Location',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete Location',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
