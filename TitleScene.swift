//
//  TitleScene.swift
//  SimpleIPADShooter
//
//  Created by Greg Willis on 2/6/16.
//  Copyright © 2016 Willis Programming. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene : SKScene {
    
    var buttonPlay : UIButton!
    var gameTitle : UILabel!
    var secondGameTitle : UILabel!
    
    var textColorHUD = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.blackColor()
        let bgImage = SKSpriteNode(imageNamed: "titlespace")
//        bgImage.size = CGSizeMake(self.frame.maxX, self.frame.height)
        bgImage.size = self.frame.size
        bgImage.zPosition = -1
        bgImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        self.addChild(bgImage)
        setUpText()
    }
    
    func setUpText() {
        buttonPlay = UIButton(frame: CGRect(x: 100, y: 100, width: 150, height: 75))
        buttonPlay.center = CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height * 0.7)
        buttonPlay.titleLabel?.font = UIFont(name: "Copperplate", size: 40)
        buttonPlay.backgroundColor = UIColor(red: (225/255), green: 0.0, blue: 0.0, alpha: 1.0)
        buttonPlay.layer.cornerRadius = 10
        buttonPlay.layer.borderWidth = 2
        buttonPlay.layer.borderColor = UIColor.whiteColor().CGColor
        buttonPlay.setTitle("Play", forState: UIControlState.Normal)
        buttonPlay.setTitleColor(textColorHUD, forState: UIControlState.Normal)
        buttonPlay.addTarget(self, action: Selector("playTheGame"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view?.addSubview(buttonPlay)
        
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view!.frame.width, height: 300))
        gameTitle!.textColor = UIColor(red: (225/255), green: 0.0, blue: 0.0, alpha: 1.0)
        gameTitle!.font = UIFont(name: "Copperplate", size: 100)
        gameTitle!.textAlignment = NSTextAlignment.Center
        gameTitle!.text = "Space"
        self.view?.addSubview(gameTitle)
        
        secondGameTitle = UILabel(frame: CGRect(x: 0, y: 100, width: view!.frame.width, height: 300))
        secondGameTitle!.textColor = UIColor(red: (225/255), green: 0.0, blue: 0.0, alpha: 1.0)
        secondGameTitle!.font = UIFont(name: "Copperplate", size: 60)
        secondGameTitle!.textAlignment = NSTextAlignment.Center
        secondGameTitle!.text = "Shooters"
        self.view?.addSubview(secondGameTitle)
    }
    
    func playTheGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFadeWithDuration(1.0))
        buttonPlay.removeFromSuperview()
        gameTitle.removeFromSuperview()
        secondGameTitle.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
    }
}