import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddUser(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.groups, color: Colors.blue),
                title: Text('User Statistics'),
                subtitle: Text('Total: 15 users • Active: 12 • Inactive: 3'),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text('All Users'),
                          trailing: Chip(label: Text('15')),
                        ),
                        ..._buildUserList(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserList(BuildContext context) {
    final users = [
      {
        'name': 'Admin User',
        'email': 'admin@restaurant.com',
        'role': 'Admin',
        'status': 'Active',
      },
      {
        'name': 'Manager One',
        'email': 'manager@restaurant.com',
        'role': 'Manager',
        'status': 'Active',
      },
      {
        'name': 'Chef Master',
        'email': 'chef@restaurant.com',
        'role': 'Chef',
        'status': 'Active',
      },
      {
        'name': 'Waiter One',
        'email': 'waiter1@restaurant.com',
        'role': 'Waiter',
        'status': 'Active',
      },
      {
        'name': 'Waiter Two',
        'email': 'waiter2@restaurant.com',
        'role': 'Waiter',
        'status': 'Inactive',
      },
      {
        'name': 'Cashier One',
        'email': 'cashier@restaurant.com',
        'role': 'Cashier',
        'status': 'Active',
      },
    ];

    return users.map((user) {
      IconData roleIcon = Icons.person;
      Color roleColor = Colors.grey;

      switch (user['role']) {
        case 'Admin':
          roleIcon = Icons.security;
          roleColor = Colors.red;
          break;
        case 'Manager':
          roleIcon = Icons.manage_accounts;
          roleColor = Colors.blue;
          break;
        case 'Chef':
          roleIcon = Icons.restaurant;
          roleColor = Colors.green;
          break;
        case 'Waiter':
          roleIcon = Icons.delivery_dining;
          roleColor = Colors.orange;
          break;
        case 'Cashier':
          roleIcon = Icons.point_of_sale;
          roleColor = Colors.purple;
          break;
      }

      return ListTile(
        leading: Icon(roleIcon, color: roleColor),
        title: Text(user['name']!),
        subtitle: Text(user['email']!),
        trailing: Chip(
          label: Text(
            user['status']!,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: user['status'] == 'Active'
              ? Colors.green
              : Colors.grey,
        ),
        onTap: () => _showUserDetails(context, user),
      );
    }).toList();
  }

  void _showUserDetails(BuildContext context, Map<String, String> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user['name']!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user['email']!),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Role'),
                subtitle: Text(user['role']!),
              ),
              ListTile(
                leading: const Icon(Icons.flag), // Changed from Icons.status
                title: const Text('Status'),
                subtitle: Text(user['status']!),
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
                      onPressed: () => _showComingSoon(context, 'Edit User'),
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

  void _showAddUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                DropdownMenuItem(value: 'Chef', child: Text('Chef')),
                DropdownMenuItem(value: 'Waiter', child: Text('Waiter')),
                DropdownMenuItem(value: 'Cashier', child: Text('Cashier')),
              ],
              onChanged: (value) {},
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
              _showComingSoon(context, 'Add User');
            },
            child: const Text('Add User'),
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
