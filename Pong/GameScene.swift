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
    
    var score: [Int] = []
    
    override func didMove(to view: SKView) {
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        mainPaddle = self.childNode(withName: "mainPaddle") as! SKSpriteNode
        enemyPaddle = self.childNode(withName: "enemyPaddle") as! SKSpriteNode
        
        ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        physicsBody = border
        
        physicsWorld.contactDelegate = self
        startGame()
    }
    
    func startGame() {
        score = [0, 0]
    }
    
    func addScore(winner: SKSpriteNode) {
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        if winner == mainPaddle {
            score[0] += 1
            resetGame()
            ball.physicsBody?.applyImpulse(CGVector(dx: -20, dy: -20))
        } else if winner == enemyPaddle {
            score[1] += 1
            resetGame()
            ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
        }
        print("SCORE ==>", score)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.contactPoint.y > 550 {
            print("user scored")
            addScore(winner: mainPaddle)
            ball.position.y = enemyPaddle.position.y - 10
        } else if contact.contactPoint.y < -550 {
            print("enemy scored")
            addScore(winner: enemyPaddle)
            ball.position.x = mainPaddle.position.y + 10
        }
    }
    
    func resetGame() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .white
        } completion: { isFinished in
            if isFinished {
                self.backgroundColor = .black
            }
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
    }

    override func update(_ currentTime: TimeInterval) {
        enemyPaddle.run(SKAction.moveTo(x: ball.position.x, duration: 0.2))
    }
}
