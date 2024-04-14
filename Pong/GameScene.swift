//
//  GameScene.swift
//  Pong
//
//  Created by Pooyan J on 1/14/1403 AP.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    enum GameState {
        case startGame, mainGoals, enemyGoals, pause
    }
    
    var ball = SKSpriteNode()
    var impulseState: GameState?
    var mainPaddle = SKSpriteNode()
    var enemyPaddle = SKSpriteNode()
    var mainScoreLabel = SKLabelNode()
    var enemyScoreLabel = SKLabelNode()
    var isBallOnMove: Bool {
        return ball.physicsBody?.velocity != .zero
    }
    var paddleContactCounter = 0 {
        didSet {
            if paddleContactCounter.isMultiple(of: 10) {
                self.physicsWorld.speed += 0.2
                setupBallEffects()
            }
        }
    }
    var score: [Int] = [] {
        didSet {
            self.physicsWorld.speed = 1
            setupBallEffects()
        }
    }
    
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
        setScore()
        startGame(state: .startGame)
    }
    
    private func createWall() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let wallSize = CGSize(width: width, height: height)
        let wallColor = UIColor.clear
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
        ball.removeAllChildren()
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.texture = SKTexture(image: UIImage(named: "ball2")!)
    }
    
    private func addParticleToBallWhileMoving() {
        switch self.physicsWorld.speed {
        case 1.0:
            setupBall()
        case 1...1.5:
            addWhiteParticleToBall()
        case 1.5...2.0:
            addFireParticleToBall()
        case 2...:
            addExplosiveParticleToBall()
        default:
            setupBall()
        }
    }
    
    private func addWhiteParticleToBall() {
        ball.texture = nil
        let snow = SKEmitterNode(fileNamed: "snow")!
        snow.targetNode = self
        ball.removeAllChildren()
        ball.addChild(snow)
    }
    
    private func addFireParticleToBall() {
        ball.texture = nil
        let fire = SKEmitterNode(fileNamed: "fire")!
        fire.targetNode = self
        ball.removeAllChildren()
        ball.addChild(fire)
    }
    
    private func addExplosiveParticleToBall() {
        ball.texture = nil
        let spark = SKEmitterNode(fileNamed: "magic")!
        spark.targetNode = self
        ball.removeAllChildren()
        ball.addChild(spark)
    }
    
    private func setupBallEffects() {
        if isBallOnMove {
            addParticleToBallWhileMoving()
        } else {
            setupBall()
        }
    }
}

// MARK: - Game Actions
extension GameScene {
    
    private func setScore() {
        score = [0, 0]
        mainScoreLabel.text = "0"
        enemyScoreLabel.text = "0"
    }
    
    private func startGame(state: GameState) {
        switch state {
        case .enemyGoals:
            impulseState = .enemyGoals
        case .mainGoals:
            impulseState = .mainGoals
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -10))
            }
        case .startGame:
            impulseState = .startGame
            ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
        case .pause:
            print("game has to pause")
        }
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
    
    private func scoreAction() {
        if ball.position.y <= mainPaddle.position.y - mainPaddle.frame.height {
            showEffectForScore(scorer: enemyPaddle)
            addScore(winner: enemyPaddle)
        } else if ball.position.y >= enemyPaddle.position.y + enemyPaddle.frame.height {
            showEffectForScore(scorer: mainPaddle)
            addScore(winner: mainPaddle)
        }
    }
    
    private func addScore(winner: SKSpriteNode) {
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // force stop the ball
        if winner == mainPaddle {
            score[0] += 1
            moveBallTo(loser: enemyPaddle)
            startGame(state: .mainGoals)
        } else if winner == enemyPaddle {
            score[1] += 1
            moveBallTo(loser: mainPaddle)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startGame(state: .enemyGoals)
            }
        } else {
            print("unsupported score state")
        }
        updateLabels()
        print(score)
    }
    
    private func moveBallTo(loser: SKSpriteNode) {
        if loser == mainPaddle {
            let startPoint = CGPoint(x: mainPaddle.position.x, y: mainPaddle.position.y + 20)
            let action = SKAction.moveBy(x: startPoint.x, y: startPoint.y, duration: 0)
            ball.run(action)
        } else if loser == enemyPaddle {
            let startPoint = CGPoint(x: enemyPaddle.position.x, y: enemyPaddle.position.y - 20)
            let action = SKAction.moveBy(x: startPoint.x, y: startPoint.y, duration: 0)
            ball.run(action)
        }
    }
    
    private func updateLabels() {
        mainScoreLabel.text = score[0].description
        enemyScoreLabel.text = score[1].description
    }
}

// MARK: - Scene Delgate Functions
extension GameScene: SCNPhysicsContactDelegate, SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let a = contact.bodyA.node?.name, let b = contact.bodyB.node?.name {
            if a == ball.name || b == ball.name {
                if a == enemyPaddle.name || b == enemyPaddle.name || a == mainPaddle.name || b == mainPaddle.name {
                    paddleContactCounter += 1
                }
            }
        }
    }
    
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
            if .enemyGoals == impulseState {
                if location.x > mainPaddle.position.x {
                    ball.physicsBody?.applyImpulse(CGVector(dx: 10, dy: 10))
                } else {
                    ball.physicsBody?.applyImpulse(CGVector(dx: -10, dy: -10))
                }
                impulseState = .startGame
            }
            mainPaddle.run(SKAction.moveTo(x: location.x, duration: 0))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        mainPaddle.color = .white
    }
    
    override func update(_ currentTime: TimeInterval) {
        enemyPaddle.run(SKAction.moveTo(x: ball.position.x, duration: 0))
        mainPaddle.run(SKAction.moveTo(x: ball.position.x, duration: 0)) // MARK: remove before commit
        scoreAction()
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
