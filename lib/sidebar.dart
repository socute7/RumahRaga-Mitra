import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mitra_rumahraga/models/user_provider.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onMenuTap;

  Sidebar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => onMenuTap('/dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Tambah'),
            onTap: () => onMenuTap('/tambah'),
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: Text('Lapangan'),
            onTap: () => onMenuTap('/edit'),
          ),
          ListTile(
            leading: Icon(Icons.inventory_2),
            title: Text('Order'),
            onTap: () => onMenuTap('/order'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/history',
                arguments: {'transactionCode': 'YOUR_DEFAULT_TRANSACTION_CODE'},
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Jadwal'),
            onTap: () => onMenuTap('/jam'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () => onMenuTap('/profile'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
