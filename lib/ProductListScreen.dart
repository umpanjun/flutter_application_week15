import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'form_page.dart'; // นำเข้าไฟล์หน้าฟอร์ม

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  final String apiUrl = 'http://172.20.10.13:8001/products';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200) {
        setState(() {
          products.removeWhere((product) => product['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบสินค้าเรียบร้อย!"), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบสินค้าไม่สำเร็จ!"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, String productName, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยืนยันการลบ"),
          content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบ $productName?"),
          actions: [
            TextButton(
              child: const Text("ยกเลิก"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("ลบ", style: TextStyle(color: Colors.red)),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product List")),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text(product['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${product['price'].toString()} บาท",
                        style: const TextStyle(color: Colors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          var updatedProduct = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormPage(product: product),
                            ),
                          );
                          if (updatedProduct != null) {
                            fetchProducts(); // โหลดสินค้าใหม่
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDeleteConfirmationDialog(context, product['name'], () {
                            deleteProduct(product['id']);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormPage()),
          );
          if (newProduct != null) {
            fetchProducts(); // โหลดสินค้าใหม่
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}