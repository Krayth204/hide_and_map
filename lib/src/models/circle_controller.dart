typedef VoidCallback = void Function();

abstract class CircleController {
  double getRadius();
  void setRadius(double radius);
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}
