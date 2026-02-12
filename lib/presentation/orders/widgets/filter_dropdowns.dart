// 📁 filter_dropdowns.dart
///
/// This file defines the [FilterDropdowns] widget, which provides a set of
/// search and filter controls for the menu items on the waiter order screen.
/// It includes a search text field, a category dropdown, a price sort dropdown,
/// and an availability filter dropdown. All changes are directly delegated
/// to the [WaiterOrderViewModel] via property setters.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import 'package:restaurant_mobile_app/presentation/orders/view_models/waiter_order_view_model.dart';

/// A stateless widget that renders the search bar and filter dropdowns.
///
/// This widget is designed to be placed inside the menu panel of the
/// [WaiterOrderScreen]. It observes the [WaiterOrderViewModel] using
/// [Consumer] and updates the view model's filter properties in real‑time.
///
/// The widget consists of:
/// - A [TextField] for searching by item name or description.
/// - A horizontal scrollable row containing three dropdowns:
///   - Category filter (allows single category selection, with an "All Categories" option).
///   - Price/rating sort (none, low to high, high to low, highest rated).
///   - Availability filter (all items or available only).
class FilterDropdowns extends StatelessWidget {
  /// The ViewModel that provides filter state and mutation methods.
  final WaiterOrderViewModel vm;

  const FilterDropdowns({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaiterOrderViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              // -------------------------------------------------------------
              // 1. Search Text Field
              // -------------------------------------------------------------
              _buildSearchField(vm),

              const SizedBox(height: 12),

              // -------------------------------------------------------------
              // 2. Filter Row (Category, Price Sort, Availability)
              // -------------------------------------------------------------
              _buildFilterRow(vm),
            ],
          ),
        );
      },
    );
  }

  /// Builds the search input field.
  ///
  /// The field is bound to [WaiterOrderViewModel.searchTerm]. A clear button
  /// appears when the search term is not empty.
  Widget _buildSearchField(WaiterOrderViewModel vm) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name or description...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: vm.searchTerm.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => vm.searchTerm = '',
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) => vm.searchTerm = value,
    );
  }

  /// Builds the horizontal row of filter dropdowns.
  ///
  /// The row is scrollable horizontally to accommodate small screen widths.
  Widget _buildFilterRow(WaiterOrderViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // ---------------------------------------------------------
          // Category Dropdown
          // ---------------------------------------------------------
          _buildCategoryDropdown(vm),

          const SizedBox(width: 8),

          // ---------------------------------------------------------
          // Price / Rating Sort Dropdown
          // ---------------------------------------------------------
          _buildPriceSortDropdown(vm),

          const SizedBox(width: 8),

          // ---------------------------------------------------------
          // Availability Filter Dropdown
          // ---------------------------------------------------------
          _buildAvailabilityDropdown(vm),
        ],
      ),
    );
  }

  /// Builds the category selection dropdown.
  ///
  /// The dropdown always shows "All Categories" as the first item.
  /// Selecting a specific category sets [vm.selectedCategories] to a list
  /// containing that single category. Selecting "All Categories" sets it
  /// to `['all']` which is interpreted by the ViewModel as "no category filter".
  Widget _buildCategoryDropdown(WaiterOrderViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: vm.selectedCategories.contains('all')
            ? 'all'
            : vm.selectedCategories.firstOrNull,
        hint: const Text('Category'),
        underline: const SizedBox(),
        items: [
          const DropdownMenuItem(value: 'all', child: Text('All Categories')),
          ...vm.categories.map(
            (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
          ),
        ],
        onChanged: (value) {
          if (value == 'all') {
            vm.selectedCategories = ['all'];
          } else {
            vm.selectedCategories = [value!];
          }
        },
      ),
    );
  }

  /// Builds the dropdown for sorting by price or rating.
  ///
  /// The options are:
  /// - `'none'`: no sorting (default order)
  /// - `'low'`: price ascending
  /// - `'high'`: price descending
  /// - `'rating'`: highest rated first
  ///
  /// The selected value is stored in [vm.priceSort].
  Widget _buildPriceSortDropdown(WaiterOrderViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: vm.priceSort,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'none', child: Text('Sort by')),
          DropdownMenuItem(value: 'low', child: Text('Price: Low to High')),
          DropdownMenuItem(value: 'high', child: Text('Price: High to Low')),
          DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
        ],
        onChanged: (value) => vm.priceSort = value!,
      ),
    );
  }

  /// Builds the dropdown for filtering by availability.
  ///
  /// Options:
  /// - `'all'`: show all items (default)
  /// - `'available'`: show only items with `availability == true`
  ///
  /// The selected value is stored in [vm.availabilityFilter].
  Widget _buildAvailabilityDropdown(WaiterOrderViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: vm.availabilityFilter,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('All Items')),
          DropdownMenuItem(value: 'available', child: Text('Available Only')),
        ],
        onChanged: (value) => vm.availabilityFilter = value!,
      ),
    );
  }
}
