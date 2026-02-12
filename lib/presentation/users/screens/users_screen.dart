import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/users/view_models/users_view_model.dart';
import 'package:restaurant_mobile_app/presentation/routes/routes.dart';

/// Displays a list of all users with admin management capabilities.
///
/// This screen depends on [UsersViewModel] for state and business operations.
/// It does not contain any business logic; only UI rendering and event forwarding.
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain the ViewModel from the provider. It is created in the route definition.
    final viewModel = Provider.of<UsersViewModel>(context, listen: true);
    final authManager = context.watch<AuthManager>();
    final currentUser = authManager.currentUser;

    if (!authManager.isLoading &&
        authManager.isAuthenticated &&
        currentUser?.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin privileges required.'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return const Scaffold(body: Center(child: Text('Redirecting...')));
    }

    // Load users when the screen is first built, if not already loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.users.isEmpty && !viewModel.isLoading) {
        viewModel.loadUsers();
      }
    });

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
            onPressed: () => _showAddUserDialog(context, viewModel),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadUsers(),
          ),
        ],
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, UsersViewModel viewModel) {
    // Show loading indicator while fetching data.
    if (viewModel.isLoading && viewModel.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message with retry option.
    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.errorMessage}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadUsers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state.
    if (viewModel.users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    // Display the user list.
    return Column(
      children: [
        _buildStatisticsCard(viewModel),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.users.length,
            itemBuilder: (context, index) {
              final user = viewModel.users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(user.roleIcon, color: user.roleColor),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          user.role,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: user.roleColor.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          user.isActive ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: user.isActive
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditUserDialog(context, viewModel, user);
                          } else if (value == 'toggle') {
                            viewModel.updateUserStatus(user.id, !user.isActive);
                          } else if (value == 'delete') {
                            _confirmDelete(context, viewModel, user);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  user.isActive
                                      ? Icons.block
                                      : Icons.check_circle,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(user.isActive ? 'Deactivate' : 'Activate'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _showUserDetails(context, viewModel, user),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds a statistics card showing total users, active, and inactive counts.
  Widget _buildStatisticsCard(UsersViewModel viewModel) {
    final total = viewModel.users.length;
    final active = viewModel.users.where((u) => u.isActive).length;
    final inactive = total - active;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.groups, color: Colors.blue),
          title: const Text('User Statistics'),
          subtitle: Text(
            'Total: $total users • Active: $active • Inactive: $inactive',
          ),
        ),
      ),
    );
  }

  /// Shows a modal bottom sheet with detailed user information.
  void _showUserDetails(
    BuildContext context,
    UsersViewModel viewModel,
    UserListItem user,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: user.roleColor.withOpacity(0.2),
                      child: Icon(user.roleIcon, color: user.roleColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user.email),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Status'),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(user.isActive ? 'Active' : 'Inactive'),
                    ],
                  ),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditUserDialog(context, viewModel, user);
                        },
                        child: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows a dialog for adding a new user.
  void _showAddUserDialog(BuildContext context, UsersViewModel viewModel) {
    // This is a placeholder; actual implementation would use a form
    // and call the appropriate ViewModel method.
    _showComingSoon(context, 'Add User');
  }

  /// Shows a dialog for editing an existing user.
  void _showEditUserDialog(
    BuildContext context,
    UsersViewModel viewModel,
    UserListItem user,
  ) {
    // This is a placeholder; actual implementation would navigate to
    // a dedicated edit screen or open a form dialog.
    _showComingSoon(context, 'Edit User');
  }

  /// Confirms deletion with the user.
  void _confirmDelete(
    BuildContext context,
    UsersViewModel viewModel,
    UserListItem user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Retrieve current user's ID from AuthManager to prevent self-deletion.
              final authManager = context.read<AuthManager>();
              final currentUserId = authManager.currentUser?.id;
              final success = await viewModel.deleteUser(
                user.id,
                currentUserId: currentUserId,
              );
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.name} deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
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
