import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'models/user_provider.dart';
import 'sidebar.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mitraId = userProvider.idMitra;

    if (mitraId != null) {
      try {
        final profileData = await Api.getUserProfile(mitraId);
        setState(() {
          _userProfile = profileData;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      drawer: Sidebar(
        onMenuTap: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _userProfile!['photo_profile'] !=
                                      null &&
                                  _userProfile!['photo_profile'].isNotEmpty
                              ? NetworkImage(
                                  '${Api.gambarUrl}/data/photo_profile/${_userProfile!['photo_profile']}')
                              : AssetImage('assets/images/user.png')
                                  as ImageProvider,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _userProfile!['name'] ?? 'No Name',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _userProfile!['email'] ?? 'No Email',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.account_box),
                          title: Text('Username'),
                          subtitle:
                              Text(_userProfile!['name'] ?? 'No Username'),
                        ),
                        ListTile(
                          leading: Icon(Icons.account_balance),
                          title: Text('Bank Account Name'),
                          subtitle: Text(
                              _userProfile!['nm_rek'] ?? 'No Account Name'),
                        ),
                        ListTile(
                          leading: Icon(Icons.account_balance_wallet),
                          title: Text('Bank Account Number'),
                          subtitle: Text(_userProfile!['no_rek'] != null
                              ? _userProfile!['no_rek'].toString()
                              : 'No Account Number'),
                        ),
                        ListTile(
                          leading: Icon(Icons.check_circle),
                          title: Text('Status'),
                          subtitle: Text(_userProfile!['status'] == 1
                              ? 'Active'
                              : 'Inactive'),
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text('Joined Date'),
                          subtitle: Text(
                              _userProfile!['created_at'] ?? 'No Joined Date'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
