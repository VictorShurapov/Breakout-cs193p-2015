//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Victor Shurapov on 3/19/18.
//  Copyright © 2018 Victor Shurapov. All rights reserved.
//

import UIKit

// MARK: - PROTOCOL

protocol  BreakoutCollisionBehaviorDelegate: AnyObject {
    func ballHitBrick(behavior: UICollisionBehavior, ball: BallView, brickIndex: Int)
    func ballLeftPlayingField(ball: BallView)
}

// MARK: - CLASS BreakoutBehavior

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    private struct Constants {
        struct Ball {
            static let MinVelocity = CGFloat(100.0)
            static let MaxVelocity = CGFloat(1400.0)
        }
    }
    
    weak var breakoutCollisionDelegate: BreakoutCollisionBehaviorDelegate?
    
    let gravity = UIGravityBehavior()
    
    // MARK: - COLLIDER
    
    private lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = false
        lazyCollider.collisionDelegate = self
        lazyCollider.action = { [unowned self] in
            
            for ball in self.balls {
                if !self.dynamicAnimator!.referenceView!.bounds.intersects(ball.frame) {
                    self.breakoutCollisionDelegate?.ballLeftPlayingField(ball: ball as BallView)
                }
                
                self.ballBehavior.limitLinearVelocity(min: Constants.Ball.MinVelocity, max: Constants.Ball.MaxVelocity, forItem: ball as BallView)
            }
        }
        return lazyCollider
    }()
    
    
    // MARK: - ballBehavior
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBallBehavior = UIDynamicItemBehavior()
        lazyBallBehavior.allowsRotation = false
        lazyBallBehavior.elasticity = 1.0
        lazyBallBehavior.friction = 0.0
        lazyBallBehavior.resistance = 0.0
        return lazyBallBehavior
    }()
    
    var gravityOn: Bool!
    
    var balls: [BallView] {
        get { return collider.items.filter{ $0 is BallView }.map{ $0 as! BallView } }
    }
    
    // MARK: - INIT
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    // MARK: - BOUNDARIES
    
    func addBoundary(path: UIBezierPath, named identifier: NSCopying) {
        removeBoundary(identifier: identifier)
        collider.addBoundary(withIdentifier: identifier, for: path)
    }
    
    func removeBoundary(identifier: NSCopying) {
        collider.removeBoundary(withIdentifier: identifier)
    }
    
    // MARK: - COLLISION BEHAVIOR
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        if let brickIndex = identifier as? Int {
            if let ball = item as? BallView {
                self.breakoutCollisionDelegate?.ballHitBrick(behavior: behavior, ball: ball, brickIndex: brickIndex)
            }
        }
    }
    
    // MARK: - BALL
    
    func addBall(ball: UIView) {
        self.dynamicAnimator?.referenceView?.addSubview(ball)
        // if gravityOn == true { gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        gravity.removeItem(ball)
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    
    func removeAllBalls() {
        for ball in balls {
            gravity.removeItem(ball)
            collider.removeItem(ball)
            ballBehavior.removeItem(ball)
            ball.removeFromSuperview()
        }
    }
    
    // brake the ball
    func stopBall(ball: UIView) -> CGPoint {
        let linVeloc = ballBehavior.linearVelocity(for: ball)
        ballBehavior.addLinearVelocity(CGPoint(x: -linVeloc.x, y: -linVeloc.y) , for: ball)
        return linVeloc
    }
    
    // throw the ball after the braking
    func startBall(ball: UIView, velocity: CGPoint) {
        ballBehavior.addLinearVelocity(velocity, for: ball)
    }
    
    // launch the ball (push)
    func launchBall(ball: UIView, magnitude: CGFloat, minAngle: Int = 0, maxAngle: Int = 360) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: .instantaneous)
        pushBehavior.magnitude = magnitude
        
        let randomAngle = minAngle + Int(arc4random_uniform(UInt32(maxAngle - minAngle)))
        let randomAngleRadian = Double(randomAngle) * Double.pi / 180.0
        pushBehavior.angle = CGFloat(randomAngleRadian)
        
        pushBehavior.action = { [weak pushBehavior] in
            if !pushBehavior!.active { self.removeChildBehavior(pushBehavior!) }
            
        }
        addChildBehavior(pushBehavior)
    }
}

// MARK: - LINEAR VELOCITY

private extension UIDynamicItemBehavior {
    func limitLinearVelocity(min: CGFloat, max: CGFloat, forItem item: UIDynamicItem) {
        assert(min < max, "min < max")
        let itemVelocity = linearVelocity(for: item)
        (item as! BallView).backgroundColor = .white
        
        switch itemVelocity.magnitude {
        case let x where x < CGFloat(700.0):
            (item as! BallView).backgroundColor = .yellow
        case let x where x < CGFloat(900.0) && x >= 700:
            (item as! BallView).backgroundColor = .orange
        case let x where x < CGFloat(1100.0) && x >= 900:
            (item as! BallView).backgroundColor = .red
        case let x where x > CGFloat(1100.0):
            (item as! BallView).backgroundColor = .magenta
        default:
            (item as! BallView).backgroundColor = .white
            
        }
        
        if itemVelocity.magnitude <= 0.0 { return }
        if itemVelocity.magnitude < min {
            let deltaVelocity = min / itemVelocity.magnitude * itemVelocity - itemVelocity
            //print("magnitude = \(itemVelocity.magnitude), delta = \(deltaVelocity)")
            addLinearVelocity(deltaVelocity, for: item)
        }
        if itemVelocity.magnitude > max {
            //print("magnitude = \(itemVelocity.magnitude)")
            (item as! BallView).backgroundColor = .magenta
            let deltaVelocity = max / itemVelocity.magnitude * itemVelocity - itemVelocity
            addLinearVelocity(deltaVelocity, for: item)
        }
    }
}

private extension CGPoint {
    var angle: CGFloat {
        get { return CGFloat(atan2(self.x, self.y)) }
    }
    var magnitude: CGFloat {
        get { return CGFloat(sqrt(self.x * self.x + self.y * self.y)) }
    }
}

//prefix func -(left: CGPoint) -> CGPoint {
//    return CGPoint(x: -left.x, y: -left.y)
//}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func *(left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}
