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
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.addAnimation(index)
            })
        }
    }

    func initCommon() {
        frame = CGRect(x: 0.0, y: 0.0, width: containerView.frame.size.width, height: containerView.frame.size.height)
    }

    func initContainerLayer() {
        containerLayer.frame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 65.0)
        containerLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        containerLayer.position = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        layer.addSublayer(containerLayer)
    }

    func initBezierPath() {
        lowBezierPath.move(to: CGPoint(x: 0.0, y: 55.0))
        lowBezierPath.addLine(to: CGPoint(x: 0.0, y: 65.0))
        lowBezierPath.addLine(to: CGPoint(x: 3.0, y: 65.0))
        lowBezierPath.addLine(to: CGPoint(x: 3.0, y: 55.0))
        lowBezierPath.addLine(to: CGPoint(x: 0.0, y: 55.0))
        lowBezierPath.close()

        middleBezierPath.move(to: CGPoint(x: 0.0, y: 15.0))
        middleBezierPath.addLine(to: CGPoint(x: 0.0, y: 65.0))
        middleBezierPath.addLine(to: CGPoint(x: 3.0, y: 65.0))
        middleBezierPath.addLine(to: CGPoint(x: 3.0, y: 15.0))
        middleBezierPath.addLine(to: CGPoint(x: 0.0, y: 15.0))
        middleBezierPath.close()

        highBezierPath.move(to: CGPoint(x: 0.0, y: 0.0))
        highBezierPath.addLine(to: CGPoint(x: 0.0, y: 65.0))
        highBezierPath.addLine(to: CGPoint(x: 3.0, y: 65.0))
        highBezierPath.addLine(to: CGPoint(x: 3.0, y: 0.0))
        highBezierPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        highBezierPath.close()
    }

    func initBars() {
        for index in 0 ... 4 {
            let bar = CAShapeLayer()
            bar.fillColor = UIColor.white.cgColor
            bar.frame = CGRect(x: CGFloat(15 * index), y: 0.0, width: 3.0, height: 65.0)
            bar.path = lowBezierPath.cgPath
            containerLayer.addSublayer(bar)
            childLayers.append(bar)
        }
    }

    func initAnimation() {
        for index in 0 ... 4 {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = lowBezierPath.cgPath
            if index % 2 == 0 {
                animation.toValue = middleBezierPath.cgPath
            } else {
                animation.toValue = highBezierPath.cgPath
            }
            animation.autoreverses = true
            animation.duration = 0.5
            animation.repeatCount = MAXFLOAT
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.77, 0.0, 0.175, 1.0)
            animations.append(animation)
        }
    }

    func addAnimation(_ index: Int) {
        childLayers[index].add(animations[index], forKey: "\(index)Animation")
    }
}
