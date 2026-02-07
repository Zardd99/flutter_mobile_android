import 'package:flutter/material.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback? onTap;
  final VoidCallback? onToggleAvailability;
  final bool showActions;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.onTap,
    this.onToggleAvailability,
    this.showActions = true,
  });

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
              // Header with name and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      menuItem.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${menuItem.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category and preparation time
              Row(
                children: [
                  if (menuItem.categoryName != null)
                    Chip(
                      label: Text(menuItem.categoryName!),
                      backgroundColor: Colors.green.shade50,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${menuItem.preparationTime} min'),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                menuItem.description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Dietary tags and availability
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dietary tags
                  if (menuItem.dietaryTags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: menuItem.dietaryTags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.orange.shade50,
                              labelStyle: const TextStyle(fontSize: 10),
                            ),
                          )
                          .toList(),
                    ),

                  // Availability chip
                  Chip(
                    label: Text(
                      menuItem.availability ? 'Available' : 'Out of Stock',
                    ),
                    backgroundColor: menuItem.availability
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    labelStyle: TextStyle(
                      color: menuItem.availability ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Chef special badge
              if (menuItem.chefSpecial)
                const Padding(
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
