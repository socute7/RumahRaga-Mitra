import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api.dart';
import 'sidebar.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'models/user_provider.dart';
import 'package:path/path.dart' as path;

class TambahScreen extends StatefulWidget {
  @override
  _TambahScreenState createState() => _TambahScreenState();
}

class _TambahScreenState extends State<TambahScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _deskripsiController = TextEditingController();
  TextEditingController _hargaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  String? _selectedKategori;
  String? _selectedKota;
  File? _image;
  List<dynamic> _categories = [];
  List<dynamic> _cities = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  int? _idMitra;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchCities();
    _fetchMitraId();
  }

  Future<void> _fetchMitraId() async {
    try {
      int? idMitra = Provider.of<UserProvider>(context, listen: false).idMitra;

      setState(() {
        _idMitra = idMitra;
      });

      if (idMitra == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID Mitra tidak tersedia')),
        );
      }
      print('Mitra ID fetched successfully: $idMitra');
    } catch (error) {
      print('Failed to fetch mitra_id: $error');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await Api.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  Future<void> _fetchCities() async {
    try {
      final cities = await Api.fetchCities();
      setState(() {
        _cities = cities;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cities')),
      );
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final imageFile = _image;

        final data = {
          'name': _namaController.text,
          'mitra_id': _idMitra.toString(),
          'description': _deskripsiController.text,
          'price': _hargaController.text,
          'category_id': _selectedKategori,
          'city_id': _selectedKota,
          'address': _alamatController.text,
          'is_available': '1',
        };

        final response = await Api.addLapangan(data, image: imageFile);
        print('Response received: $response');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );

        _resetForm();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TambahScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (error) {
        if (!mounted) return;
        print('Error adding lapangan: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan data lapangan')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _namaController.clear();
    _deskripsiController.clear();
    _hargaController.clear();
    _alamatController.clear();
    setState(() {
      _selectedKategori = null;
      _selectedKota = null;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data Lapangan'),
        backgroundColor: Colors.teal,
      ),
      drawer: Sidebar(
        onMenuTap: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lapangan',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Masukkan nama lapangan',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter nama lapangan';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: _idMitra != null
                    ? 'ID Mitra: $_idMitra'
                    : 'ID Mitra tidak tersedia',
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'ID Mitra',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'ID Mitra tidak tersedia',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  prefixIcon: Icon(Icons.card_membership, color: Colors.grey),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Produk',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Masukkan deskripsi produk',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter deskripsi produk';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: 'Harga Produk',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Masukkan harga produk',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter harga produk';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownSearch<String>(
                items: _categories.map((category) {
                  return category['name'].toString();
                }).toList(),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                    hintText: 'Pilih kategori produk',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                selectedItem: _selectedKategori,
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = _categories
                        .firstWhere((category) => category['name'] == value)[
                            'category_id']
                        .toString();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownSearch<Map<String, dynamic>>(
                items: _cities.isNotEmpty
                    ? _cities
                        .map((city) => {
                              'city_id': city['city_id'].toString(),
                              'nama': city['nama'],
                            })
                        .toList()
                    : [],
                selectedItem: _cities.isNotEmpty
                    ? _cities.firstWhere(
                        (city) => city['city_id'] == _selectedKota,
                        orElse: () => {'city_id': '', 'nama': 'Pilih Kota'},
                      )
                    : null,
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search city',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.green,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return ListTile(
                      leading: Icon(Icons.location_city),
                      title: Text(
                        item['nama'],
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.green : Colors.black,
                        ),
                      ),
                      tileColor:
                          isSelected ? Colors.green.withOpacity(0.1) : null,
                    );
                  },
                  menuProps: MenuProps(
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    backgroundColor: Colors.white,
                  ),
                ),
                dropdownBuilder: (context, selectedItem) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1.5),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_city),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedItem != null
                                ? selectedItem['nama']
                                : "Pilih Kota",
                            style: TextStyle(
                              color: selectedItem == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onChanged: (Map<String, dynamic>? value) {
                  setState(() {
                    _selectedKota = value?['city_id'];
                  });
                },
                validator: (value) {
                  if (value == null || value['city_id'] == '') {
                    return 'Please choose a city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  hintText: 'Masukkan alamat produk',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter alamat produk';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image != null
                      ? Image.file(_image!)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.green,
                              size: 40,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tambah Foto Produk',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
