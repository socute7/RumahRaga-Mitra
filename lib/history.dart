import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'sidebar.dart';
import 'models/user_provider.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  void fetchTransactions() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      int? mitraId = userProvider.idMitra;

      if (mitraId != null) {
        List<dynamic> fetchedTransactions =
            await Api.getTransactionsByMitraId(mitraId);
        // Filter transactions with status 1
        setState(() {
          transactions = fetchedTransactions
              .where((transaction) => transaction['status'] == 1)
              .toList();
        });
      } else {
        print('Mitra ID is null');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _savePDF() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Permission denied');
      return;
    }

    final pdf = pw.Document();

    final fontData = await rootBundle.load('assets/fonts/Schyler-Regular.ttf');
    final font = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              return pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ID Transaksi: ${transaction['transaction_id']}',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        'Code Transaksi: ${transaction['transaction_code']}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('Field ID: ${transaction['field_id']}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('Total Price: ${transaction['total_price']}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('Created At: ${transaction['created_at']}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );

    try {
      final directory = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      final path = '${directory.path}/transactions.pdf';
      print('Saving PDF to: $path');

      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      print('PDF saved successfully.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved at $path')),
      );

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is your PDF',
      );

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the PDF!');
      } else {
        print('Failed to share the PDF.');
      }
    } catch (e) {
      print('Failed to save PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _savePDF,
          ),
        ],
      ),
      drawer: Sidebar(
        onMenuTap: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
      body: transactions.isEmpty
          ? Center(
              child: Text('No transactions available',
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                var transaction = transactions[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                        'ID Transaksi: ${transaction['transaction_id']}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Code Transaksi: ${transaction['transaction_code']}'),
                        Text('Field ID: ${transaction['field_id']}'),
                        Text('Total Price: ${transaction['total_price']}'),
                        Text('Created At: ${transaction['created_at']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
