//
//  GameScene.swift
//  SimpleIPADShooter
//
//  Created by Greg Willis on 2/4/16.
//  Copyright (c) 2016 Willis Programming. All rights reserved.
//

import SpriteKit

var player = SKSpriteNode?()
var projectile = SKSpriteNode?()
var enemy = SKSpriteNode?()
var stars = SKSpriteNode?()

var scoreLabel = SKLabelNode?()
var mainLabel = SKLabelNode?()

var fireProjectileRate = 0.2
var projectileSpeed = 0.9

var enemySpeed = 5.0
var enemySpawnRate = 0.6
let starsSpawnTime = 0.3
var scoreNumber = 10


var isAlive = true

var score = 0

var textColorHUD = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

struct physicsCategory {
    static let player : UInt32 = 1
    static let enemy : UInt32 = 2
    static let projectile : UInt32 = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.blackColor()

        spawnPlayer()
        spawnScoreLabel()
        spawnMainLabel()
        spawnProjectile()
        spawnEnemy()
        spawnStars()
        fireProjectile()
        randomEnemyTimerSpawn()
        starsSpawnTimer()
        updateScore()
        hideLabel()
        resetVariablesOnStart()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            
            if isAlive == true {
                player?.position.x = touchLocation.x
            }
            if isAlive == false {
                player?.position.x = -200
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if isAlive == false {
            player?.position.x = -200
        }
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "SpaceShip")
        player?.size = CGSizeMake(50, 70)
        player?.position = CGPoint(x: CGRectGetMidX(self.frame), y: 130)
        player?.physicsBody = SKPhysicsBody(rectangleOfSize: (player?.size)!)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player?.physicsBody?.dynamic = false
        
        self.addChild(player!)
    }
    
    func spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Copperplate")
        scoreLabel?.fontSize = 50
        scoreLabel?.fontColor = textColorHUD
        scoreLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: 50)
        scoreLabel?.text = "Score"
        
        self.addChild(scoreLabel!)
    }
    
    func spawnMainLabel() {
        mainLabel = SKLabelNode(fontNamed: "Copperplate")
        mainLabel?.fontSize = 100
        mainLabel?.fontColor = textColorHUD
        mainLabel?.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        mainLabel?.text = "Start"
        
        self.addChild(mainLabel!)
        
    }
    
    func spawnProjectile() {
        projectile = SKSpriteNode(imageNamed: "Projectile")
        projectile?.size = CGSizeMake(15, 25)
        projectile!.position = CGPoint(x: (player?.position.x)!, y: (player?.position.y)!)
        projectile?.physicsBody = SKPhysicsBody(rectangleOfSize: (projectile?.size)!)
        projectile?.physicsBody?.affectedByGravity = false
        projectile?.physicsBody?.categoryBitMask = physicsCategory.projectile
        projectile?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        projectile?.physicsBody?.dynamic = false
        projectile?.zPosition = -1
        
        let moveForward = SKAction.moveToY(1000, duration: projectileSpeed)
        let destroy = SKAction.removeFromParent()
        
        projectile!.runAction(SKAction.sequence([moveForward, destroy]))
        self.addChild(projectile!)
    }
    
    func spawnEnemy() {
        enemy = SKSpriteNode(imageNamed: "Enemy")
        enemy?.size = CGSizeMake(40, 40)
        enemy!.position = CGPoint(x: CGFloat(arc4random_uniform(700) + 300), y: CGRectGetMaxY(self.frame))
        enemy?.physicsBody = SKPhysicsBody(rectangleOfSize: enemy!.size)
        enemy?.physicsBody?.affectedByGravity = false
        enemy?.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy?.physicsBody?.contactTestBitMask = physicsCategory.projectile
        enemy?.physicsBody?.allowsRotation = false
        enemy?.physicsBody?.dynamic = true
        
        var moveForward = SKAction.moveToY(-100, duration: enemySpeed)
        let destroy = SKAction.removeFromParent()
        
        enemy!.runAction(SKAction.sequence([moveForward, destroy]))

        if isAlive == false {
            moveForward = SKAction.moveToY(2000, duration: 1.0)
        }
        self.addChild(enemy!)
    }
    
    func spawnExplosion(enemyTemp: SKSpriteNode) {
        let explosionEmitterPath : NSString = NSBundle.mainBundle().pathForResource("explosion", ofType: "sks")!
        let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionEmitterPath as String) as! SKEmitterNode
        explosion.position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        explosion.zPosition = 1
        explosion.targetNode = self
        
        self.addChild(explosion)
        
        let explosionTimerRemove = SKAction.waitForDuration(0.5)
        let removeExplosion = SKAction.runBlock {
            explosion.removeFromParent()
        }
        self.runAction(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }
    
    func spawnStars() {
        let randomSize = Int(arc4random_uniform(7) + 1)
        let randomSpeed = Double(arc4random_uniform(4) + 1)
       
        stars = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: randomSize, height: randomSize))
        stars?.position = CGPoint(x: Int(arc4random_uniform(700) + 300), y: 800)
        stars?.zPosition = -2
        
        let moveForward = SKAction.moveToY(-100, duration: randomSpeed)
        let destroy = SKAction.removeFromParent()
        
        stars?.runAction(SKAction.sequence([moveForward, destroy]))
        self.addChild(stars!)
    }
    
    func fireProjectile() {
        let fireProjectileTimer = SKAction.waitForDuration(fireProjectileRate)
        
        let spawn = SKAction.runBlock {
            self.spawnProjectile()
        }
        
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func randomEnemyTimerSpawn() {
        let spawnEnemyTimer = SKAction.waitForDuration(enemySpawnRate)
        
        let spawn = SKAction.runBlock {
            self.spawnEnemy()
        }
        
        let sequence = SKAction.sequence([spawnEnemyTimer, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func starsSpawnTimer() {
        let starsTimer = SKAction.waitForDuration(starsSpawnTime)
        let spawn = SKAction.runBlock {
            self.spawnStars()
        }
        
        let sequence = SKAction.sequence([starsTimer, spawn])
        self.runAction(SKAction.repeatActionForever(sequence))
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == physicsCategory.projectile) && (secondBody.categoryBitMask == physicsCategory.enemy) || (firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.projectile)) {
            
            spawnExplosion(firstBody.node as! SKSpriteNode)
            projectileCollision(firstBody.node as! SKSpriteNode, projectileTemp: secondBody.node as! SKSpriteNode)
        }
        
        if((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy) || (firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.player)) {
            
            if let firstNode = firstBody.node as? SKSpriteNode, secondNode = secondBody.node as? SKSpriteNode {
                enemyPlayerCollision(firstNode, playerTemp: secondNode)
            }
        }
    }
    
    func projectileCollision(enemyTemp: SKSpriteNode, projectileTemp: SKSpriteNode) {
        enemyTemp.removeFromParent()
        projectileTemp.removeFromParent()
        
        score += 1
        updateScore()
        increaseEnemySpeed()
    }
    
    func enemyPlayerCollision(enemyTemp: SKSpriteNode, playerTemp: SKSpriteNode) {
        mainLabel?.fontSize = 50
        mainLabel?.alpha = 1.0
        mainLabel?.text = "Game Over"
        
        player?.removeFromParent()
        isAlive = false
        waitThenMoveToTitleScreen()
    }
    
    func waitThenMoveToTitleScreen() {
        let wait = SKAction.waitForDuration(1.0)
        let transition = SKAction.runBlock {
            self.view?.presentScene(TitleScene(), transition: SKTransition.crossFadeWithDuration(0.3))
        }
        let sequence = SKAction.sequence([wait, transition])
        self.runAction(SKAction.repeatAction(sequence, count: 1))
    }
    
    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
    }
    
    func hideLabel() {
        let wait = SKAction.waitForDuration(2.0)
        let fadeOut = SKAction.fadeOutWithDuration(1.0)
        let hide = SKAction.runBlock {
//            mainLabel?.alpha = 0.0
            mainLabel?.runAction(fadeOut)
        }
        let sequence = SKAction.sequence([wait, hide])
        self.runAction(SKAction.repeatAction(sequence, count: 1))
    }
    
    func resetVariablesOnStart() {
        isAlive = true
        score = 0
        scoreNumber = 10
        enemySpeed = 5.0
    }
    
    func increaseEnemySpeed() {
        if score ==  scoreNumber {
            enemySpeed -= 0.5
            printLevelUp()
            hideLabel()
            scoreNumber += 10
        }
    }
    
    func printLevelUp() {
        mainLabel?.fontSize = 50
        mainLabel?.alpha = 1.0
        mainLabel?.text = "Level Up"
    }
}
