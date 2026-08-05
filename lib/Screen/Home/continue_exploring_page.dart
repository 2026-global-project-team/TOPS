import 'package:flutter/material.dart';

class ContinueExploringPage extends StatelessWidget {
  const ContinueExploringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
        title: const Text(
          'Continue Exploring',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          40,
        ),
        itemCount: 8,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 18,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          return _ExploringCard(
            name: 'Local Place ${index + 1}',
          );
        },
      ),
    );
  }
}

class _ExploringCard extends StatelessWidget {
  const _ExploringCard({
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE7E8ED),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Color(0xFFA1A3AB),
                    size: 34,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 17,
                    color: Color(0xFF6883FF),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 11,
              color: Color(0xFF8B8B8B),
            ),
            SizedBox(width: 3),
            Text(
              'London, UK',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFF8B8B8B),
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.star,
              size: 11,
              color: Colors.amber,
            ),
            SizedBox(width: 2),
            Text(
              '4.6',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFF8B8B8B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}