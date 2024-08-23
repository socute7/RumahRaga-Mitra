import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sidebar.dart';
import 'api.dart';
import 'models/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  final int mitraId;

  DashboardScreen({Key? key, required this.mitraId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int statusMitra = 1;
  double penghasilan = 0.0;
  List<dynamic> fieldsData = [];

  @override
  void initState() {
    super.initState();
    _fetchPenghasilan();
    _fetchFieldsData();
  }

  Future<void> _fetchFieldsData() async {
    try {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      int? idMitra = userProvider.idMitra;

      if (idMitra != null) {
        final List<dynamic> data =
            await Api.getFieldsByMitraId(idMitra.toString());
        setState(() {
          fieldsData = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('idMitra is null'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch data: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _fetchPenghasilan() async {
    try {
      double income = await Api.getPenghasilan(widget.mitraId);
      setState(() {
        penghasilan = income;
      });
    } catch (e) {
      print('Error fetching income: $e');
    }
  }

  void _toggleStatus() {
    setState(() {
      statusMitra = statusMitra == 1 ? 0 : 1;
      _updateStatusMitra(statusMitra);
    });
  }

  Future<void> _updateStatusMitra(int status) async {
    try {
      await Api.updateStatusMitra(widget.mitraId, status);
    } catch (e) {
      print('Error updating status: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update status. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      drawer: Sidebar(
        onMenuTap: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Penghasilan:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\Rp. $penghasilan',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fieldsData.length,
                itemBuilder: (context, index) {
                  final field = fieldsData[index];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Image.network(
                                '${Api.gambarUrl}/data/fields/${field['image']}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              field['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 37),
            Text(
              'Update Toko Buka atau Tutup',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: _toggleStatus,
              child: Text(statusMitra == 1 ? 'Tutup' : 'Buka'),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
