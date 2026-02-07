import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showComingSoon(context, 'Filter Reviews'),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star, color: Colors.amber),
                              Icon(Icons.star_half, color: Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '4.5',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Average Rating',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.reviews,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '124',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Reviews',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: ListView(children: _buildReviewList(context))),
        ],
      ),
    );
  }

  List<Widget> _buildReviewList(BuildContext context) {
    final reviews = [
      {
        'name': 'John Doe',
        'rating': 5,
        'date': '2 days ago',
        'comment': 'Excellent food and service!',
      },
      {
        'name': 'Jane Smith',
        'rating': 4,
        'date': '1 week ago',
        'comment': 'Great atmosphere, will come back.',
      },
      {
        'name': 'Bob Wilson',
        'rating': 3,
        'date': '2 weeks ago',
        'comment': 'Food was good but service was slow.',
      },
      {
        'name': 'Alice Brown',
        'rating': 5,
        'date': '3 weeks ago',
        'comment': 'Best restaurant in town!',
      },
      {
        'name': 'Charlie Davis',
        'rating': 2,
        'date': '1 month ago',
        'comment': 'Disappointed with the portion size.',
      },
    ];

    return reviews.map((review) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      (review['name'] as String).substring(0, 1),
                    ), // Cast to String
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (review['name'] as String), // Cast to String
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (review['date'] as String), // Cast to String
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRatingStars(review['rating'] as int),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                (review['comment'] as String),
                style: const TextStyle(fontSize: 14),
              ), // Cast to String
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showComingSoon(context, 'Reply'),
                    child: const Text('Reply'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.thumb_up, size: 18),
                    onPressed: () => _showComingSoon(context, 'Like'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flag, size: 18),
                    onPressed: () => _showComingSoon(context, 'Report'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
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
