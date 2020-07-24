class NewsDetails {
  int _index;
  bool _isSlider;

  bool isSlider() {
    return _isSlider;
  }

  int getIndex() {
    return _index;
  }

  NewsDetails(int index, bool isSlider) {
    _index = index;
    _isSlider = isSlider;
  }
}
