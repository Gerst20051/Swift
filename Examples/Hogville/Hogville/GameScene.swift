//
//  GameScene.swift
//  Hogville
//
//  Created by Jean-Pierre Distler on 23.08.14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

enum ColliderType: UInt32 {
    case Animal = 1
    case Food = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var movingPig: Pig?
  var lastUpdateTime: NSTimeInterval = 0.0
  var dt: NSTimeInterval = 0.0
  var homeNode = SKNode()
  var currentSpawnTime: NSTimeInterval = 5.0
  var gameOver = false
  
  override init(size: CGSize) {
    super.init(size: size)
   
    physicsWorld.gravity = CGVectorMake(0.0, 0.0)
    physicsWorld.contactDelegate = self
    
    loadLevel()
    spawnAnimal()
  }
   
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
  
    if gameOver {
      restartGame()
    }
    
    /* Called when a touch begins */
    let location = touches.anyObject()!.locationInNode(self)
    let node = nodeAtPoint(location)
     
    if node.name? == "pig" {
      let pig = node as Pig
      pig.clearWayPoints()
      pig.addMovingPoint(location)
      movingPig = pig
    }
  }
  
  override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
    let location = touches.anyObject()!.locationInNode(scene)
    if let pig = movingPig {
      pig.addMovingPoint(location)
    }
  }
  
  override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    movingPig = nil
  }
  
  override func update(currentTime: CFTimeInterval) {
    if !gameOver {
      dt = currentTime - lastUpdateTime
      lastUpdateTime = currentTime
       
      enumerateChildNodesWithName("pig", usingBlock: {node, stop in
        let pig = node as Pig
        pig.move(self.dt)
      })
      
      drawLines()
    }
  }
  
  func drawLines() {
    //1
    enumerateChildNodesWithName("line", usingBlock: {node, stop in
      node.removeFromParent()
    })
   
    //2
    enumerateChildNodesWithName("pig", usingBlock: {node, stop in
      //3
      let pig = node as Pig
      if let path = pig.createPathToMove() {          
        let shapeNode = SKShapeNode()
        shapeNode.path = path
        shapeNode.name = "line"
        shapeNode.strokeColor = UIColor.grayColor()
        shapeNode.lineWidth = 2
        shapeNode.zPosition = 1
   
        self.addChild(shapeNode)
      }
    })
  }
  
  func loadLevel () {
    //1
    let bg = SKSpriteNode(imageNamed:"bg_2_grassy")
    bg.anchorPoint = CGPoint(x: 0, y: 0)
    addChild(bg)
   
    //2
    let foodNode = SKSpriteNode(imageNamed:"trough_3_full")
    foodNode.name = "food"
    foodNode.position = CGPoint(x:250, y:200)
    foodNode.zPosition = 1
   
    // More code later
    foodNode.physicsBody = SKPhysicsBody(rectangleOfSize: foodNode.size)
    foodNode.physicsBody!.categoryBitMask = ColliderType.Food.rawValue
    foodNode.physicsBody!.dynamic = false
    addChild(foodNode)
   
    //3
    homeNode = SKSpriteNode(imageNamed: "barn")
    homeNode.name = "home"
    homeNode.position = CGPoint(x: 500, y: 20)
    homeNode.zPosition = 1
    addChild(homeNode)
   
    currentSpawnTime = 5.0
  }
  
  func spawnAnimal() {
    //1
    currentSpawnTime -= 0.2
   
    //2    
    if currentSpawnTime < 1.0 {
      currentSpawnTime = 1.0
    }
   
    let pig = Pig(imageNamed: "pig_1")
    pig.position = CGPoint(x: 20, y: Int(arc4random_uniform(300)))
    pig.name = "pig"
   
    addChild(pig)
    pig.moveRandom()
   
    runAction(SKAction.sequence([SKAction.waitForDuration(currentSpawnTime), SKAction.runBlock({
      self.spawnAnimal()
    }
    )]))
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    //1
    let firstNode = contact.bodyA.node;
    let secondNode = contact.bodyB.node;
   
    //2
    let collision = firstNode!.physicsBody!.categoryBitMask | secondNode!.physicsBody!.categoryBitMask;
   
    //3
    if collision == ColliderType.Animal.rawValue
      | ColliderType.Animal.rawValue {
      NSLog("Animal collision detected");
      handleAnimalCollision()
    } else if collision == ColliderType.Animal.rawValue | ColliderType.Food.rawValue {
      var pig: Pig!
      if firstNode!.name == "pig" {
        pig = firstNode as Pig
        pig.eat()
      } else {
        pig = secondNode as Pig
        pig.eat()
      }
    } else {
      NSLog("Error: Unknown collision category \(collision)");
    }
  }
  
  func handleAnimalCollision() {
    gameOver = true
   
    let gameOverLabel = SKLabelNode(fontNamed: "Thonburi-Bold")
    gameOverLabel.text = "Game Over!"
    gameOverLabel.name = "label"
    gameOverLabel.fontSize = 35.0
    gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 20.0)
    gameOverLabel.zPosition = 5
   
    let tapLabel = SKLabelNode(fontNamed: "Thonburi-Bold")
    tapLabel.text = "Tap to restart."
    tapLabel.name = "label"
    tapLabel.fontSize = 25.0
    tapLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 20.0)
    tapLabel.zPosition = 5
   
    addChild(gameOverLabel)
    addChild(tapLabel)
  }
  
  func restartGame() {
    enumerateChildNodesWithName("line", usingBlock: {node, stop in
      node.removeFromParent()
    })
   
    enumerateChildNodesWithName("pig", usingBlock: {node, stop in
      node.removeFromParent()
    })
   
    enumerateChildNodesWithName("label", usingBlock: {node, stop in
      node.removeFromParent()
    })
   
    currentSpawnTime = 5.0
    gameOver = false
    spawnAnimal()
  }
  
}
