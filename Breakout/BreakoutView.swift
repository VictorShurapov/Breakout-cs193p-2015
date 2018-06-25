//
//  BreakoutView.swift
//  Breakout
//
//  Created by Victor Shurapov on 3/14/18.
//  Copyright © 2018 Victor Shurapov. All rights reserved.
//

import UIKit

class BreakoutView: UIView {
    
    lazy var animator: UIDynamicAnimator = {
        UIDynamicAnimator(referenceView: self)
    }()
    
    var behavior = BreakoutBehavior()
    
    var balls: [BallView] { return self.behavior.balls }
    
    var bricks = [Int: BrickView]()
    
    lazy var paddle: PaddleView = {
        let paddle = PaddleView(frame: CGRect(origin: CGPoint.zero, size: self.paddleSize))
        self.addSubview(paddle)
        return paddle
    }()
    
    var level: [[Int]]? {
        didSet {
            if let newLevel = level, let oldLevel = oldValue {
                if newLevel == oldLevel { return }
                columns = level?[0].count
                reset()
                
            }
        }
    }
    
    var paddleWidthPercentage: Int = Constants.PaddleWidthPercentage {
        didSet {
            if paddleWidthPercentage == oldValue { return }
            resetPaddleInCenter()
        }
    }
    
    var launchSpeedModifier: Float = 1.0 {
        didSet {
            launchSpeed = Constants.minLaunchSpeed + (Constants.maxLaunchSpeed - Constants.minLaunchSpeed) * CGFloat(launchSpeedModifier)
        }
    }
    
    private var launchSpeed: CGFloat = Constants.minLaunchSpeed
    private var columns: Int?
    
    // MARK: - LIFE CYCLE
    
    func initialize() {
        self.backgroundColor = .black
        animator.addBehavior(behavior)
    }
    
    func reset() {
        resetPaddleInCenter()
    }
    
    
    // MARK: - PADDLE
    
    private var paddleSize: CGSize {
        let width = self.bounds.size.width / 100.0 * CGFloat(paddleWidthPercentage)
        return CGSize(width: width, height: CGFloat(Constants.PaddleHeight))
    }
    
    private func resetPaddleInCenter() {
        paddle.center = CGPoint.zero
        resetPaddlePosition()
    }
    
    private func resetPaddlePosition() {
        paddle.frame.size = paddleSize
        if !self.bounds.contains(paddle.frame) {
            paddle.center = CGPoint(x: self.bounds.midX, y: self.bounds.maxY - paddle.bounds.height - Constants.PaddleBottomMargin)
        } else {
            paddle.center = CGPoint(x: paddle.center.x, y: self.bounds.maxY - paddle.bounds.height - Constants.PaddleBottomMargin)
        }
        behavior.addBoundary(path: UIBezierPath(ovalIn: paddle.frame), named: Constants.PaddleBoundaryID as NSCopying )
    }
    struct Constants {
        static let PaddleBottomMargin: CGFloat = 10.0
        static let PaddleHeight: Int = 15
        static let PaddleColor = UIColor.white
        static let PaddleWidthPercentage: Int = 33
        static let PaddleBoundaryID = "paddleBoundary"
        
        static let minLaunchSpeed = CGFloat(0.2)
        static let maxLaunchSpeed = CGFloat(0.5)
    }
}

func == <E : Equatable>(lhs: [[E]], rhs: [[E]]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    
    for i in 0..<lhs.count {
        guard lhs[i] == rhs[i] else { return false }
    }
    return true
}
