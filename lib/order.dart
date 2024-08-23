import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'models/user_provider.dart';
import 'sidebar.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<dynamic> transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      int? idMitra = userProvider.idMitra;

      if (idMitra != null) {
        setState(() {
          _isLoading = true;
        });

        final List<dynamic> data = await Api.getTransactionsByMitraId(idMitra);

        setState(() {
          transactions = data;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('idMitra is null'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (transactions.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to fetch transactions: $e'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  void _acceptTransaction(Map<String, dynamic> order) async {
    try {
      await Api.updateTransactionStatus(
        transaction_code: order['transaction_code'],
        new_status: 1,
      );

      setState(() {
        order['status'] = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction accepted successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to accept transaction: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _rejectTransaction(Map<String, dynamic> order) async {
    try {
      await Api.updateTransactionStatus(
        transaction_code: order['transaction_code'],
        new_status: 0,
      );

      setState(() {
        order['status'] = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction rejected successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to reject transaction: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Screen'),
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
          : transactions.isEmpty
              ? Center(child: Text('Tidak ada data'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];

                    return FutureBuilder(
                      future: Future.wait([
                        Api.getFieldById(transaction['field_id']),
                        Api.getUserById(transaction['user_id']),
                      ]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.length < 2 ||
                            snapshot.data![0] == null ||
                            snapshot.data![1] == null) {
                          return Center(child: Text('Data not available'));
                        } else {
                          final fieldName = snapshot.data![0]['name'] ??
                              'Nama Lapangan Tidak Ditemukan';
                          final userName = snapshot.data![1]['name'] ??
                              'Nama Pengguna Tidak Ditemukan';

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transaction Code: ${transaction['transaction_code']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('Price: ${transaction['total_price']}'),
                                  Text('Nama Lapangan: $fieldName'),
                                  Text('Nama: $userName'),
                                  Text(
                                      'Order Date: ${transaction['created_at']}'),
                                  Text(
                                      'Status: ${transaction['status'] == 2 ? 'Pending' : transaction['status'] == 1 ? 'Accepted' : 'Rejected'}'),
                                  SizedBox(height: 16),
                                  if (transaction['status'] == 2)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _acceptTransaction(transaction),
                                          child: Text('Accept'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _rejectTransaction(transaction),
                                          child: Text('Reject'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
