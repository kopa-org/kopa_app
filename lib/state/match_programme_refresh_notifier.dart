import 'package:flutter/foundation.dart';

class MatchProgrammeRefreshNotifier extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  void notifyMatchesChanged() {
    _generation++;
    notifyListeners();
  }
}
