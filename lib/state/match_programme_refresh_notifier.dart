import 'package:flutter/foundation.dart';

class MatchProgrammeRefreshNotifier extends ChangeNotifier {
  int _generation = 0;

  int get generation => _generation;

  void notifyImported() {
    _generation++;
    notifyListeners();
  }
}
