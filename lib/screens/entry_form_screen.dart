import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import '../models/visitor_entry.dart';
import 'history_screen.dart';

class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({Key? key}) : super(key: key);

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _houseNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _licensePlateController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.createEntry(
        licensePlate: _licensePlateController.text.trim(),
        houseNumber: _houseNumberController.text.trim(),
      );

      if (response.error != null) {
        _showSnackBar(response.error!, isError: true);
      } else {
        _showSnackBar(response.message ?? 'บันทึกข้อมูลสำเร็จ');
        _clearForm();
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _licensePlateController.clear();
    _houseNumberController.clear();
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แอพ รปภ. - บันทึกการเข้าออก',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: 'ประวัติการเข้าออก',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.indigo.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.security, size: 50, color: Colors.indigo),
                        const SizedBox(height: 10),
                        Text(
                          'บันทึกข้อมูลผู้เข้าออก',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'กรุณากรอกข้อมูลให้ครบถ้วน',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Form Card
                Expanded(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // License Plate Field
                            TextFormField(
                              controller: _licensePlateController,
                              decoration: InputDecoration(
                                labelText: 'ป้ายทะเบียน',
                                hintText: 'เช่น กก 1234 กรุงเทพ',
                                prefixIcon: Icon(
                                  Icons.directions_car,
                                  color: Colors.indigo,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.indigo,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกป้ายทะเบียน';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // House Number Field
                            TextFormField(
                              controller: _houseNumberController,
                              decoration: InputDecoration(
                                labelText: 'บ้านเลขที่',
                                hintText: 'เช่น 123/45',
                                prefixIcon: Icon(
                                  Icons.home,
                                  color: Colors.indigo,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.indigo,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกบ้านเลขที่';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            // Save Button
                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveEntry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child:
                                    _isLoading
                                        ? const SpinKitThreeBounce(
                                          color: Colors.white,
                                          size: 20,
                                        )
                                        : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.save, size: 24),
                                            SizedBox(width: 10),
                                            Text(
                                              'บันทึกข้อมูล',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Clear Button
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _clearForm,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.indigo,
                                  side: BorderSide(color: Colors.indigo),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.clear, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'ล้างข้อมูล',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
