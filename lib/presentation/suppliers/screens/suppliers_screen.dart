import 'package:flutter/material.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.add_business, color: Colors.blue),
                title: Text('Add New Supplier'),
                subtitle: Text('Register a new supplier'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Active Suppliers'),
                    trailing: Chip(label: Text('5')),
                  ),
                  ..._buildSupplierList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplier(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildSupplierList(BuildContext context) {
    final suppliers = [
      {
        'name': 'Fresh Produce Co.',
        'contact': 'John Smith',
        'status': 'Active',
      },
      {
        'name': 'Quality Meats Ltd.',
        'contact': 'Sarah Johnson',
        'status': 'Active',
      },
      {
        'name': 'Dairy Distributors',
        'contact': 'Mike Wilson',
        'status': 'Active',
      },
      {
        'name': 'Bakery Supplies Inc.',
        'contact': 'Emily Davis',
        'status': 'Inactive',
      },
      {
        'name': 'Beverage Wholesalers',
        'contact': 'Robert Brown',
        'status': 'Active',
      },
    ];

    return suppliers.map((supplier) {
      return ListTile(
        leading: const Icon(Icons.business, color: Colors.blue),
        title: Text(supplier['name']!),
        subtitle: Text('Contact: ${supplier['contact']}'),
        trailing: Chip(
          label: Text(
            supplier['status']!,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: supplier['status'] == 'Active'
              ? Colors.green
              : Colors.grey,
        ),
        onTap: () => _showSupplierDetails(context, supplier),
      );
    }).toList();
  }

  void _showSupplierDetails(
    BuildContext context,
    Map<String, String> supplier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                supplier['name']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Contact Person'),
                subtitle: Text(supplier['contact']!),
              ),
              ListTile(
                leading: const Icon(Icons.flag), // Changed from Icons.status
                title: const Text('Status'),
                subtitle: Text(supplier['status']!),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: const Text('contact@example.com'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: const Text('+1 (555) 123-4567'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _showComingSoon(context, 'Edit Supplier'),
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSupplier(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Supplier Name'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contact Person'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Add Supplier');
            },
            child: const Text('Add'),
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
