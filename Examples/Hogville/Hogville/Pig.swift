//
//  Pig.swift
//  Hogville
//
//  Created by Main Account on 10/1/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

import Foundation
import SpriteKit

class Pig: SKSpriteNode {
  
  let POINTS_PER_SEC: CGFloat = 80.0
  var wayPoints: [CGPoint] = []
  var velocity = CGPoint(x: 0, y: 0)
  var moveAnimation: SKAction
  var hungry = true
  var eating = false
  var removing = false

  init(imageNamed name: String) {
    let texture = SKTexture(imageNamed: name)
    let textures = [SKTexture(imageNamed:"pig_1"), SKTexture(imageNamed:"pig_2"), SKTexture(imageNamed:"pig_3")]
    moveAnimation = SKAction.animateWithTextures(textures, timePerFrame:0.1)

    super.init(texture: texture, color: nil, size: texture.size())
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.0)
    physicsBody!.categoryBitMask = ColliderType.Animal.rawValue
    physicsBody!.contactTestBitMask = ColliderType.Animal.rawValue | ColliderType.Food.rawValue
    physicsBody!.collisionBitMask = 0

  }
   
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addMovingPoint(point: CGPoint) {
    wayPoints.append(point)
  }
  
  func move(dt: NSTimeInterval) {
    if !eating {
      let currentPosition = position
      var newPosition = position
     
      //1
      if wayPoints.count > 0 {
        let targetPoint = wayPoints[0]
     
        //1
        let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
        let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
        let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
        velocity = CGPoint(x: direction.x * POINTS_PER_SEC, y: direction.y * POINTS_PER_SEC)
         
        //2
        newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(dt), y:currentPosition.y + velocity.y * CGFloat(dt))
        position = newPosition
     
        //3
        if frame.contains(targetPoint) {
          wayPoints.removeAtIndex(0)
        }
      } else {
        newPosition = CGPoint(x: currentPosition.x + velocity.x * CGFloat(dt),
                                         y: currentPosition.y + velocity.y * CGFloat(dt))
        position = checkBoundaries(newPosition);
      }
    }
    
    zRotation = atan2(CGFloat(velocity.y), CGFloat(velocity.x)) + CGFloat(M_PI_2)
    checkForHome()
    if(actionForKey("moveAction") == nil) {
      runAction(moveAnimation, withKey:"moveAction")
    }
  }
  
  func createPathToMove() -> CGPathRef? {
    //1
    if wayPoints.count <= 1 {
      return nil
    }
    //2
    var ref = CGPathCreateMutable()
   
    //3
    for var i = 0; i < wayPoints.count; ++i {
      let p = wayPoints[i]
   
      //4
      if i == 0 {
        CGPathMoveToPoint(ref, nil, p.x, p.y)
      } else {
        CGPathAddLineToPoint(ref, nil, p.x, p.y)
      }
   }
   
    return ref
  }
  
  func checkBoundaries(position: CGPoint) -> CGPoint {
    //1
    var newVelocity = velocity
    var newPosition = position
   
    //2      
    let bottomLeft = CGPoint(x: 0, y: 0)
    let topRight = CGPoint(x:scene!.size.width, y:scene!.size.height)
   
    //3
    if newPosition.x <= bottomLeft.x {
      newPosition.x = bottomLeft.x
      newVelocity.x = -newVelocity.x
    } else if newPosition.x >= topRight.x {
      newPosition.x = topRight.x
      newVelocity.x = -newVelocity.x
    }
   
    if newPosition.y <= bottomLeft.y {
      newPosition.y = bottomLeft.y
      newVelocity.y = -newVelocity.y
    } else if newPosition.y >= topRight.y {
      newPosition.y = topRight.y
      newVelocity.y = -newVelocity.y
    }
   
    velocity = newVelocity
   
    return newPosition
  }
  
  func moveRandom() {
    //1
    wayPoints.removeAll(keepCapacity:false)
   
    //2
    let width = scene!.frame.width
    let height = scene!.frame.height
    
    //3
    let randomPoint = CGPoint(x:Int(arc4random_uniform(UInt32(width))),        
                              y:Int(arc4random_uniform(UInt32(height))))
    wayPoints.append(randomPoint)
    wayPoints.append(CGPoint(x:randomPoint.x + 1, y:randomPoint.y + 1))
  }
  
  func eat() {
    //1
    if hungry {
      //2
      removeActionForKey("moveAction")
      eating = true
      hungry = false
   
      //3
      let blockAction = SKAction.runBlock({
        self.eating = false
        self.moveRandom()
      })
   
      runAction(SKAction.sequence([SKAction.waitForDuration(1.0), blockAction]))
    }
  }
  
  func checkForHome() {
    //1
    if hungry || removing {
      return
    }
   
    //2
    let s = scene as GameScene       
    let homeNode = s.homeNode
   
    //3
    if frame.intersects(homeNode.frame) {
      removing = true
   
      wayPoints.removeAll(keepCapacity: false)
      removeAllActions()
      
      //4
      runAction(SKAction.sequence([
                  SKAction.group([SKAction.fadeAlphaTo(0.0, duration: 0.5),     
                  SKAction.moveTo(homeNode.position, duration: 0.5)]), 
                SKAction.removeFromParent()]))
    }
  }
  
  func clearWayPoints() {
    wayPoints.removeAll(keepCapacity: false)
  }
  
}
