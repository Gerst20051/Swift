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
    var lastLocation: CGPoint = CGPointMake(0.0, 0.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        if let scene = GameScene(size: view.frame.size) as GameScene? {
            gameScene = scene
            // gameScene!.size = CGSize(width: 10000.0, height: 10000.0)
            gameScene!.backgroundColor = UIColor.whiteColor()
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = false
            skView.multipleTouchEnabled = false
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            scene.scaleMode = .Fill
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
        let gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "detectLongPress:")
        gesture.delegate = self
        gesture.minimumPressDuration = 2.0
        self.view.addGestureRecognizer(gesture)
    }

    func createPinchGesture() {
        let gesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "detectPinch:")
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }

    func createPanGesture() {
        let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "detectPan:")
        gesture.delegate = self
        gesture.minimumNumberOfTouches = 2
        self.view.addGestureRecognizer(gesture)
    }

    func createRotationGesture() {
        let gesture: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "detectRotation:")
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }

    func detectLongPress(sender: UILongPressGestureRecognizer) {
        gameScene!.clearLines()
        if (sender.state == UIGestureRecognizerState.Ended) {
            println("Long Press Ended")
        } else if (sender.state == UIGestureRecognizerState.Began) {
            println("Long Press Began")
        }
        UIView.animateWithDuration(0.25, animations: {
            self.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))
            self.view.transform = CGAffineTransformIdentity
        })
    }

    func detectPinch(sender: UIPinchGestureRecognizer) {
        println("detectPinch => \(sender)")
        self.view.transform = CGAffineTransformScale(self.view.transform, sender.scale, sender.scale)
        sender.scale = 1
    }

    func detectPan(sender: UIPanGestureRecognizer) {
        println("detectPan => \(sender)")
        let translation  = sender.translationInView(self.view)
        self.view.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
        // sender.setTranslation(CGPointZero, inView: self.view)
    }

    func detectRotation(sender: UIRotationGestureRecognizer) {
        println("detectRotation => \(sender)")
        let angle: CGFloat = sender.rotation
        self.view.transform = CGAffineTransformRotate(self.view.transform, angle)
        sender.rotation = 0.0
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        lastLocation = self.view.center
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
