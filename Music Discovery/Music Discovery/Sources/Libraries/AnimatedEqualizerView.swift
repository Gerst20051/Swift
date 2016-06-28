//
//  AnimatedEqualizerView.swift
//  AnimatedSplash
//
//  Created by Diep Nguyen Hoang on 7/25/15.
//  Copyright (c) 2015 CodenTrick. All rights reserved.
//

import UIKit

class AnimatedEqualizerView: UIView {
    var containerView: UIView!
    let containerLayer = CALayer()
    var childLayers = [CALayer]()
    let lowBezierPath = UIBezierPath()
    let middleBezierPath = UIBezierPath()
    let highBezierPath = UIBezierPath()
    var animations = [CABasicAnimation]()
    var isShowing = false

    init(containerView: UIView) {
        self.containerView = containerView
        super.init(frame: containerView.frame)
        initCommon()
        initContainerLayer()
        initBezierPath()
        initBars()
        initAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func animate() {
        guard !isShowing else {
            return
        }
        isShowing = true
        for index in 0 ... 4 {
            let delay = 0.1 * Double(index)
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.addAnimation(index)
            })
        }
    }

    func initCommon() {
        frame = CGRectMake(0.0, 0.0, containerView.frame.size.width, containerView.frame.size.height)
    }

    func initContainerLayer() {
        containerLayer.frame = CGRectMake(0.0, 0.0, 60.0, 65.0)
        containerLayer.anchorPoint = CGPointMake(0.5, 0.5)
        containerLayer.position = CGPointMake(frame.size.width / 2.0, frame.size.height / 2.0)
        layer.addSublayer(containerLayer)
    }

    func initBezierPath() {
        lowBezierPath.moveToPoint(CGPointMake(0.0, 55.0))
        lowBezierPath.addLineToPoint(CGPointMake(0.0, 65.0))
        lowBezierPath.addLineToPoint(CGPointMake(3.0, 65.0))
        lowBezierPath.addLineToPoint(CGPointMake(3.0, 55.0))
        lowBezierPath.addLineToPoint(CGPointMake(0.0, 55.0))
        lowBezierPath.closePath()

        middleBezierPath.moveToPoint(CGPointMake(0.0, 15.0))
        middleBezierPath.addLineToPoint(CGPointMake(0.0, 65.0))
        middleBezierPath.addLineToPoint(CGPointMake(3.0, 65.0))
        middleBezierPath.addLineToPoint(CGPointMake(3.0, 15.0))
        middleBezierPath.addLineToPoint(CGPointMake(0.0, 15.0))
        middleBezierPath.closePath()

        highBezierPath.moveToPoint(CGPointMake(0.0, 0.0))
        highBezierPath.addLineToPoint(CGPointMake(0.0, 65.0))
        highBezierPath.addLineToPoint(CGPointMake(3.0, 65.0))
        highBezierPath.addLineToPoint(CGPointMake(3.0, 0.0))
        highBezierPath.addLineToPoint(CGPointMake(0.0, 0.0))
        highBezierPath.closePath()
    }

    func initBars() {
        for index in 0 ... 4 {
            let bar = CAShapeLayer()
            bar.fillColor = UIColor.whiteColor().CGColor
            bar.frame = CGRectMake(CGFloat(15 * index), 0.0, 3.0, 65.0)
            bar.path = lowBezierPath.CGPath
            containerLayer.addSublayer(bar)
            childLayers.append(bar)
        }
    }

    func initAnimation() {
        for index in 0 ... 4 {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = lowBezierPath.CGPath
            if index % 2 == 0 {
                animation.toValue = middleBezierPath.CGPath
            } else {
                animation.toValue = highBezierPath.CGPath
            }
            animation.autoreverses = true
            animation.duration = 0.5
            animation.repeatCount = MAXFLOAT
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.77, 0.0, 0.175, 1.0)
            animations.append(animation)
        }
    }

    func addAnimation(index: Int) {
        childLayers[index].addAnimation(animations[index], forKey: "\(index)Animation")
    }
}
