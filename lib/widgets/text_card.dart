import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TestCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String? bottomTitle;
  final IconData? icon;
  final String? imagesUrl;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.bottomTitle,
    this.icon,
    this.imagesUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Cached image or fallback icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imagesUrl != null && imagesUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imagesUrl!,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 40,
                          width: 40,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle, // makes it circular
                          ),
                          child: Icon(
                            icon ?? Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon ?? Icons.description,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subTitle, style: const TextStyle(fontSize: 12)),
                  Text(
                    bottomTitle != null ? bottomTitle.toString() : "",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
