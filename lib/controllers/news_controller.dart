import 'package:flutter/foundation.dart';

import '../models/news_item.dart';
import '../services/news_service.dart';

class NewsController extends ChangeNotifier {
  final NewsService _service = NewsService();

  List<NewsItem> _items = [];
  List<NewsItem> get items => List.unmodifiable(_items);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> loadNews() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getNews(limit: 15);
    } catch (e) {
      _error = e.toString();
      _items = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
