import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider([this._prefs]) {
    _ids.addAll(_prefs?.getStringList(_key) ?? const <String>[]);
  }

  static const String _key = 'favorites';

  final SharedPreferences? _prefs;
  final Set<String> _ids = <String>{};

  Set<String> get ids => Set<String>.unmodifiable(_ids);
  int get count => _ids.length;

  bool isFavorite(String productId) => _ids.contains(productId);

  void toggle(String productId) {
    if (!_ids.remove(productId)) {
      _ids.add(productId);
    }
    _persist();
    notifyListeners();
  }

  void clear() {
    _ids.clear();
    _persist();
    notifyListeners();
  }

  void _persist() {
    _prefs?.setStringList(_key, _ids.toList());
  }
}
