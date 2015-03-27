import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let scene = GameScene(size: view.frame.size) as GameScene? {
            gameScene = scene
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
            skView.ignoresSiblingOrder = false
            scene.scaleMode = .AspectFill
            scene.name = "HarmonyCanvas"
            skView.presentScene(scene)
        }
        createLongPressGesture()
    }

    func createLongPressGesture() {
        var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        gesture.minimumPressDuration = 2.0
        self.view.addGestureRecognizer(gesture)
    }

    func longPressed(longPress: UIGestureRecognizer) {
        gameScene!.clearLines()
        if (longPress.state == UIGestureRecognizerState.Ended) {
            println("Long Press Ended")
        } else if (longPress.state == UIGestureRecognizerState.Began) {
            println("Long Press Began")
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
