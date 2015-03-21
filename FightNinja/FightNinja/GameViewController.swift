//
//  GameViewController.swift
//  FightNinja
//
//  Created by Shephertz on 19/06/14.
//  Copyright (c) 2014 Shephertz. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {
    
    @IBOutlet var userNameField: UITextField?
    @IBOutlet var playAsGuestButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppWarpHelper.sharedInstance.initializeWarp()
        AppWarpHelper.sharedInstance.gameViewController = self
    }

    func startGameScene()
    {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            AppWarpHelper.sharedInstance.gameScene = scene
            skView.presentScene(scene)
        }
    }
    
    @IBAction func playAsGuest(AnyObject)
    {
        userNameField?.resignFirstResponder()
        
        var uName = userNameField?.text
        var uNameLength = uName?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if uNameLength>0
        {
            AppWarpHelper.sharedInstance.playerName = uName!
            AppWarpHelper.sharedInstance.connectWithAppWarpWithUserName(uName!)
        }
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
        // Release any cached data, images, etc that aren't in use.
    }
    
}
