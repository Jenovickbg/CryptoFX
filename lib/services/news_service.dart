import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_item.dart';

/// Actualités crypto via CryptoCompare (gratuit, pas de clé requise).
class NewsService {
  static const _base = 'https://min-api.cryptocompare.com/data/v2/news';

  final http.Client _client = http.Client();

  /// Récupère les dernières actualités (langue FR).
  Future<List<NewsItem>> getNews({int limit = 15}) async {
    try {
      final uri = Uri.parse('$_base/?lang=FR');
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 12),
          );
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['Data'] as List<dynamic>?;
      if (list == null) return [];
      final items = <NewsItem>[];
      for (var i = 0; i < list.length && items.length < limit; i++) {
        final m = list[i] as Map<String, dynamic>?;
        if (m == null) continue;
        final title = m['title'] as String?;
        final url = m['url'] as String?;
        if (title == null || title.isEmpty || url == null || url.isEmpty) {
          continue;
        }
        final publishedOn = m['published_on'];
        final ts = publishedOn is num
            ? publishedOn.toInt()
            : (publishedOn is int ? publishedOn : 0);
        final sourceInfo = m['source_info'] as Map<String, dynamic>?;
        final sourceName = sourceInfo?['name'] as String? ?? m['source'] as String? ?? '—';
        final upvotes = (m['upvotes'] is num)
            ? (m['upvotes'] as num).toInt()
            : int.tryParse(m['upvotes']?.toString() ?? '0') ?? 0;
        final downvotes = (m['downvotes'] is num)
            ? (m['downvotes'] as num).toInt()
            : int.tryParse(m['downvotes']?.toString() ?? '0') ?? 0;
        items.add(NewsItem(
          id: m['id']?.toString() ?? '$i',
          title: title,
          url: url,
          sourceName: sourceName,
          imageUrl: m['imageurl'] as String?,
          publishedOn: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
          upvotes: upvotes,
          downvotes: downvotes,
        ));
      }
      return items;
    } catch (_) {
      return [];
    }
  }
}
