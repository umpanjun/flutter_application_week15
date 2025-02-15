import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? product; // ถ้ามีค่า แปลว่าเป็นการแก้ไขสินค้า

  const FormPage({super.key, this.product});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?['name'] ?? "");
    descriptionController = TextEditingController(text: widget.product?['description'] ?? "");
    priceController = TextEditingController(text: widget.product?['price']?.toString() ?? "");
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    Map<String, dynamic> productData = {
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
    };

    String url = "http://172.20.10.13:8001/products";
    http.Response response;

    try {
      if (widget.product == null) {
        // 🟢 เพิ่มสินค้า (POST)
        response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(productData),
        );
      } else {
        // 🔵 แก้ไขสินค้า (PUT)
        url = "http://172.20.10.13:8001/products/${widget.product!['id']}";
        response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(productData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        Navigator.pop(context, responseData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "เพิ่มสินค้า" : "แก้ไขสินค้า")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "ชื่อสินค้า"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อสินค้า" : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "รายละเอียด"),
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: "ราคา"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: saveProduct,
                      child: Text(widget.product == null ? "เพิ่มสินค้า" : "บันทึกการแก้ไข"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}