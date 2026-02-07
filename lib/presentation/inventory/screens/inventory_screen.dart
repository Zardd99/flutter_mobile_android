import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showAlerts(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Low Stock', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            '3 items',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(height: 8),
                          Text('In Stock', style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            '45 items',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.inventory, color: Colors.blue),
                      title: Text('All Inventory Items'),
                      subtitle: Text('View and manage all inventory items'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.add_box, color: Colors.green),
                      title: Text('Add New Item'),
                      subtitle: Text('Add new inventory items'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text('Low Stock Alerts'),
                      subtitle: Text('View items needing restock'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recent Inventory Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(children: _buildInventoryItems()),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComingSoon(context, 'Add Inventory Item'),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildInventoryItems() {
    final items = [
      {
        'name': 'Tomatoes',
        'stock': '12 kg',
        'status': 'Low',
        'color': Colors.red,
      },
      {
        'name': 'Flour',
        'stock': '25 kg',
        'status': 'Good',
        'color': Colors.green,
      },
      {'name': 'Cheese', 'stock': '8 kg', 'status': 'Low', 'color': Colors.red},
      {
        'name': 'Olive Oil',
        'stock': '15 L',
        'status': 'Good',
        'color': Colors.green,
      },
      {
        'name': 'Chicken',
        'stock': '20 kg',
        'status': 'Good',
        'color': Colors.green,
      },
    ];

    return items.map((item) {
      return ListTile(
        leading: const Icon(Icons.local_grocery_store),
        subtitle: Text('Stock: ${item['stock']}'),
        trailing: Chip(
          // Replace lines 175-180 in inventory_screen.dart with:
          label: Text(
            (item['status'] as String),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: item['color'] as Color,
        ),
      );
    }).toList();
  }

  void _showAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventory Alerts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Tomatoes running low'),
              subtitle: Text('Only 12 kg remaining'),
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.red),
              title: Text('Cheese running low'),
              subtitle: Text('Only 8 kg remaining'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => _showComingSoon(context, 'Reorder'),
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
