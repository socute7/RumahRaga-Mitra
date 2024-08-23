import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'api.dart';
import 'sidebar.dart';
import 'package:provider/provider.dart';
import 'models/user_provider.dart';

class EditScreen extends StatefulWidget {
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  List<dynamic> fieldsData = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
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
        print('Fetched data: $data');
        setState(() {
          fieldsData = data;
        });
      } else {
        // Handle case where idMitra is null
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

  Future<void> _updateField(
      BuildContext context, Map<String, dynamic> updateData, int index) async {
    try {
      File? imageFile;
      if (_image != null) {
        imageFile = _image;
      } else {
        imageFile = null; // or handle existing image filename
      }

      final result = await Api.updateField(updateData, imageFile);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
        duration: Duration(seconds: 2),
      ));

      setState(() {
        fieldsData[index] = updateData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update field: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _deleteField(
      BuildContext context, int fieldId, int index) async {
    try {
      final result = await Api.deleteField(fieldId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message']),
        duration: Duration(seconds: 2),
      ));

      setState(() {
        fieldsData.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete field: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredFieldsData = fieldsData
        .where((field) =>
            field['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
        backgroundColor: Colors.teal,
      ),
      drawer: Sidebar(
        onMenuTap: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredFieldsData.isEmpty
                ? Center(
                    child: Text(
                      'No fields available',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filteredFieldsData.length,
                    itemBuilder: (context, index) {
                      final field = filteredFieldsData[index];
                      TextEditingController nameController =
                          TextEditingController(text: field['name']);
                      TextEditingController descriptionController =
                          TextEditingController(text: field['description']);
                      TextEditingController priceController =
                          TextEditingController(
                              text: field['price'].toString());
                      TextEditingController categoryController =
                          TextEditingController(
                              text: field['category_id'].toString());
                      TextEditingController cityController =
                          TextEditingController(
                              text: field['city_id'].toString());
                      TextEditingController imageController =
                          TextEditingController(text: field['image']);
                      TextEditingController addressController =
                          TextEditingController(text: field['address']);
                      TextEditingController isAvailableController =
                          TextEditingController(
                              text: field['is_available'].toString());

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Edit ${field['name']}'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: _image != null
                                            ? Image.file(_image!)
                                            : Image.network(
                                                '${Api.gambarUrl}/data/fields/${field['image']}',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      TextField(
                                        controller: nameController,
                                        decoration:
                                            InputDecoration(labelText: 'Name'),
                                      ),
                                      TextField(
                                        controller: descriptionController,
                                        decoration: InputDecoration(
                                            labelText: 'Description'),
                                      ),
                                      TextField(
                                        controller: priceController,
                                        decoration:
                                            InputDecoration(labelText: 'Price'),
                                        keyboardType: TextInputType.number,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: imageController,
                                              decoration: InputDecoration(
                                                  labelText: 'Upload Image'),
                                              readOnly: true,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.photo_library),
                                            onPressed: () {
                                              _pickImage();
                                            },
                                          ),
                                        ],
                                      ),
                                      TextField(
                                        controller: addressController,
                                        decoration: InputDecoration(
                                            labelText: 'Address'),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Map<String, dynamic> updateData = {
                                        'field_id': field['field_id'],
                                        'mitra_id': field['mitra_id'],
                                        'category_id':
                                            int.parse(categoryController.text),
                                        'city_id':
                                            int.parse(cityController.text),
                                        'name': nameController.text,
                                        'description':
                                            descriptionController.text,
                                        'image': _image != null
                                            ? path.basename(_image!.path)
                                            : field['image'],
                                        'address': addressController.text,
                                        'price':
                                            int.parse(priceController.text),
                                        'is_available': int.parse(
                                            isAvailableController.text),
                                      };

                                      // Debugging: print update data
                                      print(
                                          'Update data before sending: $updateData');

                                      await _updateField(
                                          context, updateData, index);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await _deleteField(
                                          context, field['field_id'], index);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    '${Api.gambarUrl}/data/fields/${field['image']}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  field['name'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Rp${field['price']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 5.0),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 5.0),
                                        Text(
                                          '${field['description']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        // Other widgets
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
  }
}
