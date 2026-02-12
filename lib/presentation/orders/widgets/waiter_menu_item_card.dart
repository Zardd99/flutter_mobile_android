import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

/// A card widget that displays a menu item for waiters to add to an order.
///
/// This widget is used in the waiter order creation screen to present a compact,
/// visually appealing preview of a [MenuItem]. It shows:
/// - An image (or placeholder icon).
/// - The item name and description.
/// - The price and, if applicable, a "Chef" special badge.
/// - An overlay when the item is unavailable.
/// - A floating action button to add the item to the cart (only if available).
///
/// The card is tappable via the [onAddToCart] callback, which is typically used
/// to add one unit of this item to the current order cart.
class WaiterMenuItemCard extends StatelessWidget {
  /// The menu item entity to display.
  final MenuItem item;

  /// Callback invoked when the user taps the add‑to‑cart button.
  ///
  /// This callback is **only** available when [item.availability] is `true`.
  /// The button is hidden when the item is unavailable.
  final VoidCallback onAddToCart;

  /// Creates a [WaiterMenuItemCard] for the given [item].
  const WaiterMenuItemCard({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Main content column (always visible, but may be dimmed).
          _buildContent(),
          // Unavailable overlay (conditionally rendered).
          if (!item.availability) _buildUnavailableOverlay(),
          // Add button (only when available).
          if (item.availability) _buildAddButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private widget builders (extracted for readability)
  // ---------------------------------------------------------------------------

  /// Builds the main column containing the image and text information.
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildName(),
              const SizedBox(height: 4),
              _buildDescription(),
              const SizedBox(height: 8),
              _buildPriceRow(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the image area with a placeholder or network image.
  Widget _buildImage() {
    return Container(
      height: 120,
      color: Colors.grey.shade200,
      child: item.imageUrl != null
          ? Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.restaurant, size: 40)),
            )
          : const Center(child: Icon(Icons.restaurant, size: 40)),
    );
  }

  /// Builds the item name (single line, ellipsis if overflow).
  Widget _buildName() {
    return Text(
      item.name,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the item description (two lines, ellipsis).
  Widget _buildDescription() {
    return Text(
      item.description,
      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the row containing the price and optional "Chef" badge.
  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (item.chefSpecial)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Chef', style: TextStyle(fontSize: 10)),
          ),
      ],
    );
  }

  /// Builds a semi‑transparent overlay with "Unavailable" text.
  ///
  /// This overlay is placed on top of the card when the item is out of stock.
  Widget _buildUnavailableOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: const Center(
          child: Text(
            'Unavailable',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Builds the small floating action button to add the item to the cart.
  ///
  /// Positioned at the bottom‑right corner of the card. The [heroTag] is
  /// generated uniquely per item to avoid hero animation conflicts.
  Widget _buildAddButton() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: FloatingActionButton.small(
        heroTag: 'add_${item.id}',
        onPressed: onAddToCart,
        child: const Icon(Icons.add),
      ),
    );
  }
}
