//
//  GameScene.swift
//  Pong
//
//  Created by Pooyan J on 1/14/1403 AP.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SCNPhysicsContactDelegate, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
    var mainPaddle = SKSpriteNode()
    var enemyPaddle = SKSpriteNode()
    var mainScoreLabel = SKLabelNode()
    var enemyScoreLabel = SKLabelNode()
    var score: [Int] = []
    
    override func didMove(to view: SKView) {
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        mainPaddle = self.childNode(withName: "mainPaddle") as! SKSpriteNode
        enemyPaddle = self.childNode(withName: "enemyPaddle") as! SKSpriteNode
        mainScoreLabel = self.childNode(withName: "mainScoreLabel") as! SKLabelNode
        enemyScoreLabel = self.childNode(withName: "enemyScoreLabel") as! SKLabelNode
        enemyScoreLabel.physicsBody = nil
        mainScoreLabel.physicsBody = nil
        
        ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 5))
        let particle = SKEmitterNode(fileNamed: "magic")!
        particle.targetNode = self
        ball.addChild(particle)
        let fire = SKEmitterNode(fileNamed: "fire")!
        ball.addChild(fire)
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        physicsBody = border
        
        physicsWorld.contactDelegate = self
        startGame()
    }
    
    func startGame() {
        score = [0, 0]
        mainScoreLabel.text = "0"
        enemyScoreLabel.text = "0"
    }
    
    func addScore(winner: SKSpriteNode) {
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // force stop the ball
        if winner == mainPaddle {
            score[0] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: -15, dy: -15))
        } else if winner == enemyPaddle {
            score[1] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: 15, dy: 15))
        }
        updateLabels()
        print(score)
    }
    
    func updateLabels() {
        mainScoreLabel.text = score[0].description
        enemyScoreLabel.text = score[1].description
    }

    func showEffectForScore(scorer: SKSpriteNode) {
        UIView.animate(withDuration: 0.3) {
            if scorer == self.mainPaddle {
                self.backgroundColor = .white
            } else if scorer == self.enemyPaddle {
                self.backgroundColor = .red
            }
        } completion: { isFinished in
            if isFinished {
                self.backgroundColor = .black
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
        }
    }

    override func update(_ currentTime: TimeInterval) {
        enemyPaddle.run(SKAction.moveTo(x: ball.position.x, duration: 0.2))
        
        if ball.position.y <= mainPaddle.position.y - 70 {
            showEffectForScore(scorer: enemyPaddle)
            addScore(winner: enemyPaddle)
        } else if ball.position.y >= enemyPaddle.position.y + 70 {
            showEffectForScore(scorer: mainPaddle)
            addScore(winner: mainPaddle)
        }
    }
}

