import UIKit
import SpriteKit

// enum SKSceneScaleMode : Int {
//     case Fill /* Scale the SKScene to fill the entire SKView. */
//     case AspectFill /* Scale the SKScene to fill the SKView while preserving the scene's aspect ratio. Some cropping may occur if the view has a different aspect ratio. */
//     case AspectFit /* Scale the SKScene to fit within the SKView while preserving the scene's aspect ratio. Some letterboxing may occur if the view has a different aspect ratio. */
//     case ResizeFill /* Modify the SKScene's actual size to exactly match the SKView. */
// }

class GameViewController: UIViewController, UIGestureRecognizerDelegate {

    var gameScene: GameScene?
    var lastLocation: CGPoint = CGPoint(x: 0.0, y: 0.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        if let scene = GameScene(size: view.frame.size) as GameScene? {
            gameScene = scene
            // gameScene!.size = CGSize(width: 10000.0, height: 10000.0)
            gameScene!.backgroundColor = UIColor.white
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = false
            skView.isMultipleTouchEnabled = false
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            scene.scaleMode = .fill
            scene.name = "HarmonyCanvas"
            skView.presentScene(scene)
            createGestures()
        }
    }

    func createGestures() {
        createLongPressGesture()
        createPinchGesture()
        createPanGesture()
        createRotationGesture()
    }

    func createLongPressGesture() {
        let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GameViewController.detectLongPress(_:)))
        gesture.delegate = self
        gesture.minimumPressDuration = 2.0
        self.view.addGestureRecognizer(gesture)
    }

    func createPinchGesture() {
        let gesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(GameViewController.detectPinch(_:)))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }

    func createPanGesture() {
        let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.detectPan(_:)))
        gesture.delegate = self
        gesture.minimumNumberOfTouches = 2
        self.view.addGestureRecognizer(gesture)
    }

    func createRotationGesture() {
        let gesture: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(GameViewController.detectRotation(_:)))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }

    func detectLongPress(_ sender: UILongPressGestureRecognizer) {
        gameScene!.clearLines()
        if sender.state == UIGestureRecognizerState.ended {
            print("Long Press Ended")
        } else if sender.state == UIGestureRecognizerState.began {
            print("Long Press Began")
        }
        UIView.animate(withDuration: 0.25, animations: {
            self.view.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            self.view.transform = CGAffineTransform.identity
        })
    }

    func detectPinch(_ sender: UIPinchGestureRecognizer) {
        print("detectPinch => \(sender)")
        self.view.transform = self.view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }

    func detectPan(_ sender: UIPanGestureRecognizer) {
        print("detectPan => \(sender)")
        let translation  = sender.translation(in: self.view)
        self.view.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
        // sender.setTranslation(CGPointZero, inView: self.view)
    }

    func detectRotation(_ sender: UIRotationGestureRecognizer) {
        print("detectRotation => \(sender)")
        let angle: CGFloat = sender.rotation
        self.view.transform = self.view.transform.rotated(by: angle)
        sender.rotation = 0.0
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.view.center
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
