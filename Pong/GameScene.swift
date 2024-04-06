//
//  GameScene.swift
//  Pong
//
//  Created by Pooyan J on 1/14/1403 AP.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var ball = SKSpriteNode()
    var mainPaddle = SKSpriteNode()
    var enemyPaddle = SKSpriteNode()
    var mainScoreLabel = SKLabelNode()
    var enemyScoreLabel = SKLabelNode()
    var score: [Int] = []
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setupScene()
    }
}

// MARK: - Setup Functions
extension GameScene {
    
    private func setupScene() {
        createWall()
        mainPaddle = self.childNode(withName: "mainPaddle") as! SKSpriteNode
        enemyPaddle = self.childNode(withName: "enemyPaddle") as! SKSpriteNode
        mainScoreLabel = self.childNode(withName: "mainScoreLabel") as! SKLabelNode
        enemyScoreLabel = self.childNode(withName: "enemyScoreLabel") as! SKLabelNode
        enemyScoreLabel.physicsBody = nil
        mainScoreLabel.physicsBody = nil
        physicsWorld.contactDelegate = self
        setupEnemyPaddle()
        setupMainPaddle()
        setupBall()
        startGame()
    }
    
    private func createWall() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let wallSize = CGSize(width: width, height: height)
        let wallColor = UIColor.red
        let wall = SKSpriteNode(color: .clear, size: wallSize)
        wall.drawBorder(color: wallColor, width: 2)
        wall.position = CGPoint(x: 0, y: 0)
        addChild(wall)
    }
    
    private func setupMainPaddle() {
        let screenHeight = UIScreen.main.bounds.height
        let yOffset: CGFloat = -50
        let position = CGPoint(x: 0, y: -screenHeight/2 - yOffset)
        mainPaddle.position = position
    }
    
    private func setupEnemyPaddle() {
        let screenHeight = UIScreen.main.bounds.height
        let yOffset: CGFloat = 50
        let position = CGPoint(x: 0, y: screenHeight/2 - yOffset)
        enemyPaddle.position = position
    }
    
    private func setupBall() {
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        let particle = SKEmitterNode(fileNamed: "magic")!
        particle.targetNode = self
        ball.addChild(particle)
        let fire = SKEmitterNode(fileNamed: "fire")!
        ball.addChild(fire)
    }
}

// MARK: - Game Actions
extension GameScene {
    
    private func startGame() {
        score = [0, 0]
        mainScoreLabel.text = "0"
        enemyScoreLabel.text = "0"
        ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
    }
    
    private func showEffectForScore(scorer: SKSpriteNode) {
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
    
    private func addScore(winner: SKSpriteNode) {
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // force stop the ball
        if winner == mainPaddle {
            score[0] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: -5, dy: -5))
        } else if winner == enemyPaddle {
            score[1] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 5))
        }
        updateLabels()
        print(score)
    }
    
    private func updateLabels() {
        mainScoreLabel.text = score[0].description
        enemyScoreLabel.text = score[1].description
    }
}

// MARK: - Scene Delgate Functions
extension GameScene: SCNPhysicsContactDelegate, SKPhysicsContactDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
            mainPaddle.color = .green
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        mainPaddle.color = .white
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

extension SKSpriteNode {
 
    func drawBorder(color: UIColor, width: CGFloat) {
        let shapeNode = SKShapeNode(rect: frame)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        let border = SKPhysicsBody(edgeLoopFrom: shapeNode.frame)
        border.friction = 0
        border.restitution = 1
        physicsBody = border
        addChild(shapeNode)
    }
}
