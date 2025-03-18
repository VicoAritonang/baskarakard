import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class DetailArtikel extends StatelessWidget {
  final Map<String, dynamic> artikel;

  const DetailArtikel({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    // Format date if it exists
    String formattedDate = '';
    if (artikel['tanggal'] != null) {
      try {
        final DateTime date = artikel['tanggal'].toDate();
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = artikel['tanggal'].toString();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share functionality could be added here
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              // Bookmark functionality could be added here
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient overlay
            Stack(
              children: [
                // Main image
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: artikel['gambar'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Title overlay at the bottom of the image
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags or categories if available
                      if (artikel['kategori'] != null)
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5D5FEF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                artikel['kategori'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Article title
                      Text(
                        artikel['judul'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Article metadata
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  // Author avatar (if available)
                  if (artikel['authorImage'] != null)
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(artikel['authorImage']),
                    )
                  else
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  const SizedBox(width: 12),
                  // Author and date info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artikel['author'] ?? 'Satrio Wahyu Priambodo',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formattedDate.isNotEmpty ? 'Published on $formattedDate' : '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Reading time estimate (optional)
                  if (artikel['isi'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_estimateReadingTime(artikel['isi'])} min read',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Divider(color: Colors.grey.shade200),
            ),
            
            // Article content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Format the content with proper spacing between paragraphs
                  ..._formatContentWithParagraphs(artikel['isi']),
                  
                  // Source citation if available
                  if (artikel['sumber'] != null) ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Source:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(artikel['sumber']),
                        ],
                      ),
                    ),
                  ],
                  
                  // Related articles section (placeholder)
                  const SizedBox(height: 40),
                  const Text(
                    'Related Articles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // This would normally be populated from a related articles query
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Related articles would appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Optional floating action button for comments or interaction
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5D5FEF),
        child: const Icon(Icons.comment),
        onPressed: () {
          // Show comments or interaction options
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comments feature coming soon!')),
          );
        },
      ),
    );
  }
  
  // Estimate reading time based on word count (average person reads ~200-250 words per minute)
  int _estimateReadingTime(String text) {
    final wordCount = text.split(' ').length;
    return (wordCount / 200).ceil(); // Round up to nearest minute
  }
  
  // Format content with proper paragraph spacing
  List<Widget> _formatContentWithParagraphs(String content) {
    final paragraphs = content.split('\n\n');
    if (paragraphs.length == 1) {
      // If no double line breaks, try single line breaks
      return content.split('\n').map((paragraph) {
        return Column(
          children: [
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList();
    }
    
    return paragraphs.map((paragraph) {
      return Column(
        children: [
          Text(
            paragraph,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}