import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_app/res/app_url.dart';
import '../../Constants/appColors.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;  // To store the selected category
  List<String> _categories = ['Pills', 'Injection', 'Syrup', 'Ointment']; // Predefined categories

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the page loads
  }

  Future<void> _fetchProducts() async {
     String url = AppUrl.getProudcuts; // Replace with your actual API URL
    final Map<String, dynamic> body = {'pharmacy_id': 4}; // API body

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success']) {
          // Parse the product data and update the state
          final products = List<ProductModel>.from(
            responseData['data']['products'].map(
                  (product) => ProductModel(
                productName: product['name'],
                productCategory: _categories[0], // Default category (for now)
              ),
            ),
          );
          setState(() {
            _products = products;
            _filteredProducts = products; // Initially showing all products
          });
        } else {
          print('Error: ${responseData['message']}');
        }
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _filterProducts();
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      // Filter products based on both search term and category
      _filteredProducts = _products.where((product) {
        bool matchesCategory = _selectedCategory == null || product.productCategory == _selectedCategory;
        bool matchesSearch = product.productName.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TextColorWhite,
        automaticallyImplyLeading: false,
          title: const Text('Product List')),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () async {
                      final selectedCategory = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Select Category'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: _categories.map((category) {
                                  return ListTile(
                                    title: Text(category),
                                    onTap: () {
                                      Navigator.pop(context, category);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      );
                      if (selectedCategory != null) {
                        _onCategorySelected(selectedCategory);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: TextColorWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1,color: Colors.grey)
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10, top: 10),
                          hintText: 'Search...',
                        ),
                        onChanged: (_) {
                          _filterProducts(); // Trigger filtering whenever the user types
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Icon(Icons.filter_list_sharp, color: PRIMARY_COLOR, size: 35),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredProducts.isEmpty ? 1 : _filteredProducts.length,
                itemBuilder: (context, index) {
                  if (_filteredProducts.isEmpty) {
                    return Center(child: Text('No products found.'));
                  }
                  final product = _filteredProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.productName, style: const TextStyle(fontSize: 16)),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: PRIMARY_COLOR,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController productCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: PRIMARY_COLOR),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: productCategoryController,
                decoration: InputDecoration(
                  labelText: 'Product Category',
                  labelStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: PRIMARY_COLOR),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: PRIMARY_COLOR)),
            ),
            ElevatedButton(
              onPressed: () {
                if (productNameController.text.isNotEmpty &&
                    productCategoryController.text.isNotEmpty) {
                  setState(() {
                    _products.add(ProductModel(
                      productName: productNameController.text,
                      productCategory: productCategoryController.text,
                    ));
                    _filterProducts(); // Re-filter after adding a new product
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class ProductModel {
  final String productName;
  final String productCategory;

  ProductModel({required this.productName, required this.productCategory});
}
