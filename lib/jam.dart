import 'dart:convert';
import 'package:flutter/material.dart';
import 'api.dart';
import 'sidebar.dart';
import 'package:provider/provider.dart';
import 'models/user_provider.dart';

class JamScreen extends StatefulWidget {
  @override
  _JamScreenState createState() => _JamScreenState();
}

class _JamScreenState extends State<JamScreen> {
  Future<Map<int, List<dynamic>>> _fetchOrderDatesAndTimes(
      List<dynamic> fieldsData) async {
    final Map<int, List<dynamic>> orderDatesAndTimes = {};
    for (var field in fieldsData) {
      int fieldId = field['field_id'];
      int categoryId = field['category_id'];
      if (categoryId == 13) {
        continue; // Skip category_id 13
      }
      try {
        final orderDatesData = await Api.getOrderDateByFieldId(fieldId);
        final List<dynamic> times = [];

        if (orderDatesData.isEmpty) {
          // Use default dates if no order dates are found
          final defaultDates = _generateDefaultDates();
          for (var date in defaultDates) {
            final jams = await Api.getJamByFieldId(fieldId, date);
            times.add({'date': date, 'jams': jams});
          }
        } else {
          for (var orderDate in orderDatesData) {
            final date = orderDate['order_date'];
            final jams = await Api.getJamByFieldId(fieldId, date);
            times.add({'date': date, 'jams': jams});
          }
        }
        orderDatesAndTimes[fieldId] = times;
      } catch (e) {
        print('Error fetching order dates and times for field_id $fieldId: $e');
      }
    }
    return orderDatesAndTimes;
  }

  List<String> _generateDefaultDates() {
    final List<String> dates = [];
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      dates.add(
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
    }
    return dates;
  }

  Future<Map<String, dynamic>> _fetchFieldsData() async {
    try {
      final UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      int? idMitra = userProvider.idMitra;

      if (idMitra != null) {
        final List<dynamic> data =
            await Api.getFieldsByMitraId(idMitra.toString());
        final orderDatesAndTimes = await _fetchOrderDatesAndTimes(data);

        return {'fieldsData': data, 'orderDatesAndTimes': orderDatesAndTimes};
      } else {
        throw Exception('idMitra is null');
      }
    } catch (e) {
      print('Error fetching fields data: $e');
      rethrow;
    }
  }

  Future<void> _selectDateTime(BuildContext context, DateTime initialDateTime,
      ValueChanged<DateTime> onDateTimeSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
      );
      if (pickedTime != null) {
        final selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, pickedTime.hour, pickedTime.minute);
        onDateTimeSelected(selectedDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal'),
        backgroundColor: Colors.teal,
      ),
      drawer: Sidebar(
        onMenuTap: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchFieldsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load data: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData ||
              snapshot.data!['fieldsData'].isEmpty) {
            return Center(
              child: Text('No fields available'),
            );
          } else {
            final fieldsData = snapshot.data!['fieldsData'];
            final orderDatesAndTimes = snapshot.data!['orderDatesAndTimes'];

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.8,
              ),
              itemCount: fieldsData.length,
              itemBuilder: (context, index) {
                final field = fieldsData[index];
                final fieldId = field['field_id'];
                final categoryId = field['category_id'];
                if (categoryId == 13) {
                  return Container(); // Ignore category_id 13
                }
                final times = orderDatesAndTimes[fieldId] ?? [];

                return GestureDetector(
                  onTap: () async {
                    if (times.isNotEmpty) {
                      try {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Jam ${field['name']}'),
                                    ],
                                  ),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children:
                                            times.map<Widget>((timeEntry) {
                                          final date = timeEntry['date'];
                                          final jams = timeEntry['jams'];

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  date,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(height: 8),
                                                Container(
                                                  height: 150,
                                                  child: GridView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: jams.length,
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 4,
                                                      childAspectRatio: 2,
                                                    ),
                                                    itemBuilder:
                                                        (context, jamIndex) {
                                                      final jam =
                                                          jams[jamIndex];

                                                      return GestureDetector(
                                                        onTap: () {},
                                                        child: Card(
                                                          color:
                                                              (jam['is_available'] ==
                                                                      0)
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green,
                                                          child: Center(
                                                            child: Text(
                                                              jam['jam'],
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      } catch (e) {
                        print('Error fetching jams: $e');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to load jams: $e'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              '${Api.gambarUrl}/data/fields/${field['image']}',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            field['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
