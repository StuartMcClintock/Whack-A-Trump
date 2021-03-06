//
//  SelectModeScene.swift
//  Alien-Attack
//
//  Created by Stuart McClintock on 7/5/20.
//  Copyright © 2020 Stuart McClintock. All rights reserved.
//

import Foundation
import SpriteKit

import GoogleMobileAds

class SelectModeScene: SKScene{
    var del: AppDelegate!
    var soundButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        let app = UIApplication.shared
        del = app.delegate as? AppDelegate
        if let banner = del.bottomBanner{
            view.addSubview(banner)
        }
        
        let background = SKSpriteNode(imageNamed: "whitehouse")
        background.position = CGPoint(x:frame.midX, y:frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        addSceneButtons()
        initSoundButton()
        displayCoinInfo()
        displayMercInfo()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchedNode = atPoint(touch.location(in: self))
            if touchedNode.name == "blitz"{
                del.isBlitz = true
                del.highScore = UserDefaults.standard.integer(forKey: "highScore-blitz")
                del.buttonSound()
                startGame()
            }
            if touchedNode.name == "standard"{
                del.isBlitz = false
                del.highScore = UserDefaults.standard.integer(forKey: "highScore-standard")
                del.buttonSound()
                startGame()
            }
            if touchedNode.name == "awards"{
                del.buttonSound()
                dispAwards()
            }
            if touchedNode.name == "sound"{
                soundPressed()
                del.buttonSound()
            }
            if touchedNode.name == "store"{
                del.buttonSound()
                visitStore()
            }
        }
    }
    
    func addSceneButtons(){
        let buttonSize = CGSize(width: 500, height: 120)
        
        let standardButtonColor = SKColor.init(displayP3Red: 71/255, green: 145/255, blue: 214/255, alpha: 1)
        let blitzButtonColor = SKColor.red
        let awardButtonColor = SKColor.init(displayP3Red: 184/255, green: 156/255, blue: 20/255, alpha: 1)
        let storeButtonColor = SKColor.init(displayP3Red: 17/255, green: 125/255, blue: 7/255, alpha: 1)
        
        
        let standardPointPosition = CGPoint(x: frame.midX, y: frame.midY+460)
        let blitzPointPosition = CGPoint(x: frame.midX, y: frame.midY+280)
        let awardPointPosition = CGPoint(x: frame.midX, y: frame.midY+100)
        let storePointPosition = CGPoint(x: frame.midX, y: frame.midY-80)
        
        let standardButton = SKSpriteNode(color: standardButtonColor, size: buttonSize)
        standardButton.position = standardPointPosition
        standardButton.name = "standard"
        addChild(standardButton)
        let standardText = SKLabelNode(text: "Standard")
        standardText.position = CGPoint(x:standardPointPosition.x, y:standardPointPosition.y-25)
        standardText.fontName = "DIN Alternate Bold"
        standardText.fontColor = SKColor.white
        standardText.fontSize = 74
        standardText.name = "standard"
        addChild(standardText)
        
        let blitzButton = SKSpriteNode(color: blitzButtonColor, size: buttonSize)
        blitzButton.position = blitzPointPosition
        blitzButton.name = "blitz"
        addChild(blitzButton)
        let blitzText = SKLabelNode(text: "BLITZ ! !")
        blitzText.position = CGPoint(x:blitzPointPosition.x, y:blitzPointPosition.y-27)
        blitzText.fontName = "DIN Alternate Bold"
        blitzText.fontColor = SKColor.white
        blitzText.fontSize = 74
        blitzText.name = "blitz"
        addChild(blitzText)
        
        let awardButton = SKSpriteNode(color: awardButtonColor, size: buttonSize)
        awardButton.position = awardPointPosition
        awardButton.name = "awards"
        addChild(awardButton)
        let awardText = SKLabelNode(text: "View Awards")
        awardText.position = CGPoint(x:awardPointPosition.x, y:awardPointPosition.y-25)
        awardText.fontName = "DIN Alternate Bold"
        awardText.fontColor = SKColor.white
        awardText.fontSize = 68
        awardText.name = "awards"
        addChild(awardText)
        
        let storeButton = SKSpriteNode(color: storeButtonColor, size: buttonSize)
        storeButton.position = storePointPosition
        storeButton.name = "store"
        addChild(storeButton)
        let storeText = SKLabelNode(text: "Visit Store")
        storeText.position = CGPoint(x:storePointPosition.x, y:storePointPosition.y-25)
        storeText.fontName = "DIN Alternate Bold"
        storeText.fontColor = SKColor.white
        storeText.fontSize = 68
        storeText.name = "store"
        addChild(storeText)
    }
    
    func displayCoinInfo(){
        let offsetX:CGFloat = 160
        let offsetY:CGFloat = 255
        let coinDist:CGFloat = 65
        
        let goldLabel = SKLabelNode(fontNamed: "DIN Alternate Bold")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let labelText = formatter.string(from: NSNumber(value:del.numGold))
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.verticalAlignmentMode = .center
        goldLabel.text = labelText
        goldLabel.position = CGPoint(x: frame.midX-offsetX, y: frame.midY-offsetY)
        goldLabel.fontColor = SKColor.white
        goldLabel.fontSize = 70
        if (del.numGold >= 100000000000){
            goldLabel.fontSize = 50
        }
        addChild(goldLabel)
        
        let goldImage = SKSpriteNode(texture: del.coinFrames[0])
        goldImage.position = CGPoint(x:frame.midX-offsetX-coinDist, y:frame.midY-offsetY)
        goldImage.size = CGSize(width: 75, height: 75)
        addChild(goldImage)
        goldImage.run(SKAction.repeatForever(SKAction.animate(with: del.coinFrames, timePerFrame: 0.04, resize: false, restore: true)), withKey: "rotatingCoin")
    }
    
    func displayMercInfo(){
        let offsetX:CGFloat = 160
        let offsetY:CGFloat = 375
        let imgDist:CGFloat = 65
        
        let mercImg = SKSpriteNode(imageNamed: "mercenaryAlien-white")
        mercImg.position = CGPoint(x:frame.midX-offsetX-imgDist, y:frame.midY-offsetY)
        mercImg.size = CGSize(width: 85, height: 85)
        addChild(mercImg)
        
        let mercLabel = SKLabelNode(fontNamed: "DIN Alternate Bold")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let labelText = formatter.string(from: NSNumber(value:del.numMercs))
        mercLabel.horizontalAlignmentMode = .left
        mercLabel.verticalAlignmentMode = .center
        mercLabel.text = labelText
        mercLabel.position = CGPoint(x: frame.midX-offsetX, y: frame.midY-offsetY)
        mercLabel.fontColor = SKColor.white
        mercLabel.fontSize = 70
        addChild(mercLabel)
    }
    
    func initSoundButton(){
        if del.isMute{
            soundButton = SKSpriteNode(imageNamed: "notMute")
        }
        else{
            soundButton = SKSpriteNode(imageNamed: "mute")
        }
        soundButton.size = CGSize(width: 100, height: 100)
        soundButton.position = CGPoint(x: frame.midX, y: 175)
        soundButton.name = "sound"
        addChild(soundButton)
    }
    
    func soundPressed(){
        del.isMute = !del.isMute
        UserDefaults.standard.set(del.isMute, forKey: "isMute")
        if del.isMute{
            soundButton.texture = SKTexture(imageNamed: "notMute")
        }
        else{
            soundButton.texture = SKTexture(imageNamed: "mute")
        }
    }
    
    func startGame(){
        let scene = GameScene(fileNamed: "GameScene")
        scene?.scaleMode = .fill
        self.view?.presentScene(scene!, transition: .crossFade(withDuration: 0.5))
    }
    
    func dispAwards(){
        let scene = GameScene(fileNamed: "AwardDisplayScene")
        scene?.scaleMode = .fill
        self.view?.presentScene(scene!, transition: .doorsOpenVertical(withDuration: 0.4))
    }
    
    func visitStore(){
        let scene = GameScene(fileNamed: "StoreScene")
        scene?.scaleMode = .fill
        self.view?.presentScene(scene!, transition: .doorsOpenVertical(withDuration: 0.4))
    }
}
