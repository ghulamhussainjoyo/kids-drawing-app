import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

}

/// Children swipe near the screen edges while coloring. Deferring the system
/// edge gestures means a stray swipe only shows the grabber instead of
/// opening Notification Center, Control Center or the app switcher.
///
/// Also reports which landscape edge holds the notch over
/// `kids_drawing/notch`. iOS gives equal left and right safe-area insets in
/// landscape, so the side has to come from the interface orientation.
class DrawingViewController: FlutterViewController {
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }

  private var notchChannel: FlutterMethodChannel?
  private var reportedNotchSide: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    let channel = FlutterMethodChannel(name: "kids_drawing/notch", binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "getNotchSide" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let side = self?.currentNotchSide() ?? "none"
      self?.reportedNotchSide = side
      result(side)
    }
    notchChannel = channel
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    reportNotchSideIfChanged()
  }

  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: nil) { [weak self] _ in
      self?.reportNotchSideIfChanged()
    }
  }

  private func currentNotchSide() -> String {
    let insets = view.safeAreaInsets
    guard insets.left > 0 || insets.right > 0 else { return "none" }
    switch view.window?.windowScene?.interfaceOrientation {
    case .landscapeLeft: return "right"
    case .landscapeRight: return "left"
    default: return "none"
    }
  }

  private func reportNotchSideIfChanged() {
    let side = currentNotchSide()
    guard side != reportedNotchSide else { return }
    reportedNotchSide = side
    notchChannel?.invokeMethod("notchSideChanged", arguments: side)
  }
}
