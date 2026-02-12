// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/presentation/orders/widgets/quick_filters.dart
// Description: A horizontal scrollable row of filter chips for quickly
//              filtering menu items by categories like "Popular",
//              "Chef's Picks", "Vegetarian", and "Fast Prep".
//              Listens to WaiterOrderViewModel for active filter state.
// *****************************************************************************

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_mobile_app/presentation/orders/view_models/waiter_order_view_model.dart';

/// A horizontal, scrollable set of quick‑filter chips.
///
/// This widget displays a row of [FilterChip]s, each representing a
/// predefined filter category (e.g., "All Items", "Popular", "Chef's Picks").
/// It listens to [WaiterOrderViewModel] via [Consumer] to reflect and
/// update the currently active quick filter.
///
/// When a chip is tapped, the ViewModel's `activeQuickFilter` property
/// is updated, which typically triggers a rebuild and filters the displayed
/// menu items accordingly.
class QuickFilters extends StatelessWidget {
  /// The ViewModel that holds the state of the waiter order screen,
  /// including the currently selected quick filter.
  final WaiterOrderViewModel vm;

  const QuickFilters({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    // Consumer rebuilds whenever the ViewModel notifies its listeners.
    // The `vm` parameter from the constructor is not used directly inside;
    // instead we rely on the Provider to obtain the current instance.
    return Consumer<WaiterOrderViewModel>(
      builder: (context, viewModel, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'All Items',
                isSelected: viewModel.activeQuickFilter == 'all',
                onSelected: (_) => viewModel.activeQuickFilter = 'all',
              ),
              _FilterChip(
                label: '🔥 Popular',
                isSelected: viewModel.activeQuickFilter == 'popular',
                onSelected: (_) => viewModel.activeQuickFilter = 'popular',
              ),
              _FilterChip(
                label: '👨‍🍳 Chef\'s Picks',
                isSelected: viewModel.activeQuickFilter == 'chef',
                onSelected: (_) => viewModel.activeQuickFilter = 'chef',
              ),
              _FilterChip(
                label: '🌱 Vegetarian',
                isSelected: viewModel.activeQuickFilter == 'veg',
                onSelected: (_) => viewModel.activeQuickFilter = 'veg',
              ),
              _FilterChip(
                label: '⚡ Fast Prep',
                isSelected: viewModel.activeQuickFilter == 'fast',
                onSelected: (_) => viewModel.activeQuickFilter = 'fast',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE HELPER WIDGET
// ---------------------------------------------------------------------------

/// A styled [FilterChip] used inside [QuickFilters].
///
/// Provides consistent appearance for quick‑filter chips:
///   - Light grey background when not selected.
///   - Light blue background with a blue checkmark when selected.
///   - 8px right margin for horizontal spacing.
class _FilterChip extends StatelessWidget {
  /// The text displayed on the chip.
  final String label;

  /// Whether this chip represents the currently active filter.
  final bool isSelected;

  /// Callback invoked when the chip is tapped.
  ///
  /// The boolean parameter indicates the new selected state.
  /// In this implementation, chips are mutually exclusive,
  /// so the callback is always called with `true` and the ViewModel
  /// sets the filter accordingly.
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
      ),
    );
  }
}
