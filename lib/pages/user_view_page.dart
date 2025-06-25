import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_booking_app/model/user.dart';

class UserViewPage extends StatefulWidget {
  const UserViewPage({Key? key}) : super(key: key);

  @override
  State<UserViewPage> createState() => _UserViewPageState();
}

class _UserViewPageState extends State<UserViewPage> {
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
      debugPrint('UserViewPage: Search query changed to: $_searchQuery');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
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
                  .collection('users')
                  .where('userType', isNotEqualTo: 'admin')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  debugPrint(
                      'UserViewPage: StreamBuilder Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No non-admin users found.'));
                }

                final allUsers = snapshot.data!.docs;
                final filteredUsers = allUsers.where((userDoc) {
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final userName = userData['name']?.toLowerCase() ?? '';
                  final userEmail = userData['email']?.toLowerCase() ?? '';
                  return userName.contains(_searchQuery) ||
                      userEmail.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                      child: Text('No users found matching "${_searchQuery}"'));
                } else if (filteredUsers.isEmpty) {
                  return const Center(
                      child: Text('No non-admin users added yet.'));
                }
                debugPrint(
                    'UserViewPage: Displaying ${filteredUsers.length} filtered users.');

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredUsers[index];
                    final user =
                        AppUser.fromMap(userDoc.data() as Map<String, dynamic>);

                    return _UserListItem(user: user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final AppUser user;

  const _UserListItem({
    Key? key,
    required this.user,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.blue.shade100,
              ),
              child: Icon(
                user.gender.toLowerCase() == 'male'
                    ? Icons.person
                    : Icons.person_2_rounded,
                size: 30,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Phone: ${user.phone}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${user.userType.toUpperCase()}',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
