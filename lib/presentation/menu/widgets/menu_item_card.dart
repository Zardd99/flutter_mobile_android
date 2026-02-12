import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

/// A card widget that displays a summary of a [MenuItem].
///
/// This widget is used in menu listings (e.g., in the admin panel or customer menu)
/// to present a compact, information‑rich preview of a single menu item.
/// It shows the item's name, price, description, category, preparation time,
/// dietary tags, availability, and a "Chef's Special" badge.
///
/// The card is tappable via [onTap] and can optionally display interactive
/// actions: a delete button and a toggle‑availability chip. Both actions
/// are controlled via callbacks and can be hidden by setting [showActions] to
/// `false`.
class MenuItemCard extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor parameters
  // ---------------------------------------------------------------------------

  /// The menu item entity to display.
  final MenuItem menuItem;

  /// Callback invoked when the card is tapped (e.g., to view details).
  final VoidCallback onTap;

  /// Optional callback invoked when the availability chip is tapped.
  /// If provided and [showActions] is true, the availability chip becomes
  /// tappable and calls this function.
  final VoidCallback? onToggleAvailability;

  /// Optional callback invoked when the delete icon is pressed.
  /// If provided and [showActions] is true, a delete button is shown.
  final VoidCallback? onDelete;

  /// Whether to display action elements (delete button, availability toggle).
  /// Defaults to `true`. Set to `false` for a read‑only presentation.
  final bool showActions;

  /// Creates a [MenuItemCard] with the required [menuItem] and [onTap].
  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.onTap,
    this.onToggleAvailability,
    this.onDelete,
    this.showActions = true,
  });

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 8),
              _buildInfoRow(),
              const SizedBox(height: 8),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildFooterRow(),
              if (menuItem.chefSpecial) _buildChefSpecialBadge(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private widget builders
  // ---------------------------------------------------------------------------

  /// Builds the top row containing the item name, price, and optional delete button.
  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Item name (truncated if too long)
        Expanded(
          child: Text(
            menuItem.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Row(
          children: [
            // Price, formatted to two decimal places
            Text(
              '\$${menuItem.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            // Delete button – only shown if both showActions and onDelete are provided
            if (showActions && onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: onDelete,
                tooltip: 'Delete item',
              ),
          ],
        ),
      ],
    );
  }

  /// Builds the row with category and preparation time chips.
  Widget _buildInfoRow() {
    return Row(
      children: [
        if (menuItem.categoryName != null) _buildCategoryChip(),
        if (menuItem.categoryName != null) const SizedBox(width: 8),
        _buildPreparationTimeChip(),
      ],
    );
  }

  /// Builds the category chip (if a category name is available).
  Widget _buildCategoryChip() {
    return Chip(
      label: Text(menuItem.categoryName!),
      backgroundColor: Colors.green.shade50,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  /// Builds the preparation time chip.
  Widget _buildPreparationTimeChip() {
    return Chip(
      label: Text('${menuItem.preparationTime} min'),
      backgroundColor: Colors.blue.shade50,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  /// Builds the description text with two‑line ellipsis.
  Widget _buildDescription() {
    return Text(
      menuItem.description,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the bottom row containing dietary tags and the availability chip.
  Widget _buildFooterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dietary tags – shown as a wrap of small chips
        if (menuItem.dietaryTags.isNotEmpty) _buildDietaryTags(),
        // Availability toggle – only if enabled and callback provided
        if (showActions && onToggleAvailability != null)
          _buildAvailabilityChip(),
      ],
    );
  }

  /// Builds a wrap of dietary tag chips.
  Widget _buildDietaryTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: menuItem.dietaryTags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.orange.shade50,
              labelStyle: const TextStyle(fontSize: 10),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }

  /// Builds a tappable chip that toggles the item's availability status.
  Widget _buildAvailabilityChip() {
    return GestureDetector(
      onTap: onToggleAvailability,
      child: Chip(
        label: Text(menuItem.availability ? 'Available' : 'Out of Stock'),
        backgroundColor: menuItem.availability
            ? Colors.green.shade50
            : Colors.red.shade50,
        labelStyle: TextStyle(
          color: menuItem.availability ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the "Chef's Special" badge, displayed only when the item is marked as such.
  Widget _buildChefSpecialBadge() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 16),
          SizedBox(width: 4),
          Text(
            "Chef's Special",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
