import Flutter
import UIKit
import GoogleSignIn

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
      return
    }
    GIDSignIn.sharedInstance.handle(url)
  }
}
