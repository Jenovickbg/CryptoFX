/// Un article d'actualité crypto (source: CryptoCompare).
class NewsItem {
  final String id;
  final String title;
  final String url;
  final String sourceName;
  final String? imageUrl;
  final DateTime publishedOn;
  final int upvotes;
  final int downvotes;

  const NewsItem({
    required this.id,
    required this.title,
    required this.url,
    required this.sourceName,
    this.imageUrl,
    required this.publishedOn,
    this.upvotes = 0,
    this.downvotes = 0,
  });
}
