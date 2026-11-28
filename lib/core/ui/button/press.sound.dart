/// Which press sound a button makes.
///
/// The app's rule: going forward sounds one way, leaving sounds another.
enum PressSound {
  /// Opening a screen, picking a tool, any ordinary tap.
  enter,

  /// Back, close, cancel — anything that leaves where you are.
  exit,
}
