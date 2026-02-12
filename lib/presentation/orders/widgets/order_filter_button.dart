import 'package:flutter/material.dart';

/// A button that displays a filter menu for order statuses.
///
/// This widget presents a [PopupMenuButton] containing a list of order status
/// filters (e.g., All Orders, Pending, Confirmed, etc.). When the user selects
/// a filter, the [onFilterChanged] callback is invoked with the corresponding
/// status value (`null` for "All Orders", otherwise a status string).
///
/// The button icon is a standard filter list icon.
class OrderFilterButton extends StatelessWidget {
  /// Callback triggered when a filter is selected.
  ///
  /// Receives the selected status value:
  /// - `null` : All Orders
  /// - `'pending'`, `'confirmed'`, `'preparing'`, `'ready'`, `'served'`, `'cancelled'`
  final Function(String?) onFilterChanged;

  const OrderFilterButton({super.key, required this.onFilterChanged});

  // ---------------------------------------------------------------------------
  // Filter definitions – extracted for clarity and maintainability
  // ---------------------------------------------------------------------------

  /// List of available filter options.
  ///
  /// Each entry is a [MapEntry] where the key is the status value passed to
  /// the callback, and the value is the display label shown in the menu.
  static const List<MapEntry<String?, String>> _filterOptions = [
    MapEntry(null, 'All Orders'),
    MapEntry('pending', 'Pending'),
    MapEntry('confirmed', 'Confirmed'),
    MapEntry('preparing', 'Preparing'),
    MapEntry('ready', 'Ready'),
    MapEntry('served', 'Served'),
    MapEntry('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      onSelected: onFilterChanged,
      itemBuilder: (context) {
        // Generate PopupMenuItem widgets from the static filter list.
        return _filterOptions.map((entry) {
          return PopupMenuItem<String?>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList();
      },
      icon: const Icon(Icons.filter_list),
    );
  }
}
