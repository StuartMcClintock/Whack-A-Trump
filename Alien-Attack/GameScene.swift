//
//  GameScene.swift
//  Alien-Attack
//
//  Created by Stuart McClintock on 5/5/20.
//  Copyright © 2020 Stuart McClintock. All rights reserved.
//

import SpriteKit
import GameplayKit

import AVFoundation
//import AudioToolbox

class GameScene: SKScene {
    var del: AppDelegate!
    
    var audioPlayer: AVAudioPlayer?
    
    var scoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    
    var faces = [SKSpriteNode]()
    var poofs = [SKEmitterNode?]()
    
    let numCols = 6
    let numRows = 5
    
    var bazooka:SKSpriteNode?
    var bazookaTapRegion:SKSpriteNode?
    var bazookaPos:CGPoint?
    var rotationStarted:CFAbsoluteTime?
    
    var scoreVal = 0{
        didSet{
            scoreLabel.text = "Score: \(scoreVal)"
        }
    }
    var highScoreVal = 0{
        didSet{
            if (del.isBlitz){
                highScoreLabel.text = "Blitz High Score: \(highScoreVal)"
            }
            else{
                highScoreLabel.text = "High Score: \(highScoreVal)"
            }
        }
    }
    
    let MAX_FACES = 5
    
    var waitTime = 0.0
    var waitTimeMultiplier = 0.0
    
    // Constants for Standard Mode
    let SWT = 0.5
    let SWTM = 0.994
    
    // Constants for Blitz Mode
    let BWT = 0.5
    let BWTM = 0.963
    
    var totalVisible = 0
    //let visibleLock = NSLock()
    
    var gameOver = false
    
    var mercImage: SKSpriteNode!
    
    override func didMove(to view: SKView){
        let app = UIApplication.shared
        del = app.delegate as? AppDelegate
        del.bottomBanner?.removeFromSuperview()
        if let banner = del.topBanner{
            view.addSubview(banner)
        }
        
        bazookaPos = CGPoint(x: frame.midX, y: frame.maxY-350)
        
        if (del.isBlitz){
            waitTime = BWT
            waitTimeMultiplier = BWTM
        }
        else{
            waitTime = SWT
            waitTimeMultiplier = SWTM
        }
        
        let background = SKSpriteNode(imageNamed: "whitehouse")
        background.position = CGPoint(x:frame.midX, y:frame.midY)
        background.blendMode = .replace
        background.zPosition = -1;
        addChild(background)
        
        
        scoreLabel = SKLabelNode(fontNamed: "DIN Alternate Bold")
        scoreLabel.text = "Score: 0"
        //scoreLabel.position = CGPoint(x:85, y:30)
        scoreLabel.position = CGPoint(x:45, y:40)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 50
        addChild(scoreLabel)
        
        highScoreLabel = SKLabelNode(fontNamed: "DIN Alternate Bold")
        var xShift = 255.0
        if (del.highScore > 999){
            xShift = 285.0
        }
        if (del.isBlitz){
            xShift += 80
        }
        highScoreLabel.position = CGPoint(x:frame.maxX-CGFloat(xShift), y:48)
        highScoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.fontSize = 36
        highScoreLabel.fontColor = .black
        addChild(highScoreLabel)
        highScoreVal = del.highScore
        
        let gapX = (frame.maxX)/CGFloat(numRows)
        let gapY = (frame.midY)/CGFloat(numCols)
        
        for row in 0..<numRows {
            for col in 0..<numCols {
                addFace(at: CGPoint(x:70+Int(gapX*CGFloat(row)), y:Int(frame.midY)-Int(CGFloat(col)*gapY)+50), name:String(col)+","+String(row))
                poofs.append(nil)
            }
        }
        
        initMercImg()
        addBazooka()
        //dispFaces()
    }
    
    func initMercImg(){
        mercImage = SKSpriteNode(texture: SKTexture(imageNamed: "mercenaryAlien-clickable"), size: CGSize(width: 144, height: 120))
        mercImage.position = CGPoint(x: 80, y: frame.maxY-375)
        mercImage.name = "Merc Button"
        addChild(mercImage)
        updateMercs()
    }
    
    func updateMercs(){
        if del.numMercs == 0{
            mercImage.texture = SKTexture(imageNamed: "mercenaryAlien-notClickable")
            mercImage.alpha = 0.25
        }
    }
    
    func addFace(at position: CGPoint, name:String){
        let newFace = SKSpriteNode(imageNamed: "greenAlien")
        newFace.position = position
        newFace.zPosition = 1
        newFace.alpha = 0
        newFace.name = name
        newFace.size = del.greenAlienSize
        addChild(newFace)
        faces.append(newFace)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchedNode = atPoint(touch.location(in: self))
            let name:String = touchedNode.name ?? ""
            if name == "Merc Button"{
                if (!gameOver){
                    mercButtonTapped()
                }
                return
            }
            if name == "bazookaTapRegion"{
                fireBazooka()
                return
            }
            if name == ""{
                return
            }
            let splitCoords = name.components(separatedBy: ",")
            let col = splitCoords[0]
            let row = splitCoords[1]
            if (!gameOver){
                processTap(col: Int(col)!, row: Int(row)!)
            }
        }
    }
    
    func mercButtonTapped(){
        if del.numMercs == 0{
            return
        }
        del.numMercs -= 1
        for row in 0..<numRows{
            for col in 0..<numCols{
                processTap(col: col, row: row)
            }
        }
        waitTime = waitTime/(pow(waitTimeMultiplier, 5))
        updateMercs()
    }
    
    func processTap(col: Int, row: Int){
        if (faces[col+row*numCols].alpha == 1){
            scoreVal += 1
            if (scoreVal > highScoreVal){
                highScoreVal = scoreVal
                highScoreLabel.fontColor = SKColor.red
            }
            totalVisible -= 1
            
            faces[col+row*numCols].alpha = 0
            if let poof = SKEmitterNode(fileNamed: "Disappear"){
                poof.position = faces[col+row*numCols].position
                poofs[col+row*numCols] = poof
                addChild(poof)
            }
            
            sensoryFeedback()
        }
    }
    
    func sensoryFeedback(){
        //AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
        
        if (!del.isMute){
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
                try AVAudioSession.sharedInstance().setActive(true)
                
                let soundPath = Bundle.main.path(forResource: "alienDestroyed", ofType: "wav")
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath!))
                audioPlayer?.play()
            }
            catch {}
        }
    }
    
    func dispFaces(){
        if (gameOver){
            return
        }
        waitTime *= waitTimeMultiplier
        
        var dispNum = Int.random(in: 0..<(numCols*numRows))
        while (faces[dispNum].alpha == 1){
            dispNum = Int.random(in: 0..<(numCols*numRows))
        }
        
        // Hide potential leftover animations from last time face was tapped
        faces[dispNum].alpha = 1
        if (poofs[dispNum] != nil){
            poofs[dispNum]?.removeFromParent()
            poofs[dispNum] = nil
        }
        
        totalVisible += 1
        
        if (totalVisible >= MAX_FACES){
            del.recentScore = scoreVal
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.27, execute: { [weak self] in
                self?.endScene()
            })
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime, execute: { [weak self] in
            self?.dispFaces()
        })
    }
    
    func endScene(){
        UserDefaults.standard.set(del.numMercs, forKey: "numMercs")
        del.topBanner?.removeFromSuperview()
        
        if (totalVisible >= MAX_FACES){
            gameOver = true
            del.addGold(score: scoreVal)
            endingAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.20, execute: { [weak self] in
                self?.chooseNextScene()
            })
        }
        else{
            dispFaces()
        }
    }
    
    func endingAnimation(){
        endingNoise()
        
        let smilingAlien = SKSpriteNode(imageNamed: "smilingAlien")
        smilingAlien.position = CGPoint(x: frame.midX, y: frame.midY+135)
        smilingAlien.size = CGSize(width: 706, height: 850)
        smilingAlien.alpha = 0.2
        smilingAlien.zPosition = 2
        addChild(smilingAlien)
        
        let fade = SKAction.fadeAlpha(to: 1.0, duration: 4)
        smilingAlien.run(fade)
    }
    
    func endingNoise(){
        if (!del.isMute){
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
                try AVAudioSession.sharedInstance().setActive(true)
                
                let soundPath = Bundle.main.path(forResource: "lossNoises", ofType: "wav")
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath!))
                audioPlayer?.play()
                audioPlayer?.setVolume(0, fadeDuration: 4)
            }
            catch {}
        }
    }
    
    func chooseNextScene(){
        if (del.isBlitz && scoreVal >= del.BLITZ_BRONZE_SCORE){
            if (scoreVal >= del.BLITZ_GOLD_SCORE){
                if (!UserDefaults.standard.bool(forKey: "blitzGold")||scoreVal <= del.highScore){
                    goToAwardScene()
                }
                else{
                    goToOverScene()
                }
            }
            else if (scoreVal >= del.BLITZ_SILVER_SCORE){
               if (!UserDefaults.standard.bool(forKey: "blitzSilver")||scoreVal <= del.highScore){
                   goToAwardScene()
               }
               else{
                   goToOverScene()
               }
            }
            else if (scoreVal >= del.BLITZ_BRONZE_SCORE){
                if (!UserDefaults.standard.bool(forKey: "blitzBronze")||scoreVal <= del.highScore){
                    goToAwardScene()
                }
                else{
                    goToOverScene()
                }
            }
        }
        else if (!del.isBlitz && scoreVal >= del.STAN_BRONZE_SCORE){
            if (scoreVal >= del.STAN_GOLD_SCORE){
                if (!UserDefaults.standard.bool(forKey: "standardGold") || scoreVal <= del.highScore){
                    goToAwardScene()
                }
                else{
                    goToOverScene()
                }
            }
            else if (scoreVal >= del.STAN_SILVER_SCORE){
               if (!UserDefaults.standard.bool(forKey: "standardSilver") || scoreVal <= del.highScore){
                   goToAwardScene()
               }
                else{
                    goToOverScene()
                }
            }
            else if (scoreVal >= del.STAN_BRONZE_SCORE){
                if (!UserDefaults.standard.bool(forKey: "standardBronze") || scoreVal <= del.highScore){
                    goToAwardScene()
                }
                else{
                    goToOverScene()
                }
            }
        }
        else{
            goToOverScene()
        }
    }
    
    func goToOverScene(){
        let overScene = GameScene(fileNamed: "GameOverScene")
        overScene?.scaleMode = .fill
        self.view?.presentScene(overScene!, transition: .flipVertical(withDuration: 0.5))
    }
    
    func goToAwardScene(){
        let awardScene = GameScene(fileNamed: "ReceiveAwardScene")
        awardScene?.scaleMode = .aspectFill
        if UIDevice.current.model == "iPad"{
            awardScene?.scaleMode = .fill
        }
        self.view?.presentScene(awardScene!, transition: .flipVertical(withDuration: 0.5))
        
    }
    
    func addBazooka(){
        let verticalHeight:CGFloat = 360
        let verticalWidth:CGFloat = 225
        let startingRads:CGFloat = 0.75
        let rotationLen:TimeInterval = 2
        
        bazooka = SKSpriteNode(imageNamed: "bazooka")
        bazooka?.size = CGSize(width: verticalHeight, height: verticalWidth)
        bazooka?.position = bazookaPos!
        addChild(bazooka!)
        let rotation = SKAction.repeatForever(SKAction.sequence([SKAction.rotate(byAngle: CGFloat(Double.pi)-startingRads*2, duration: rotationLen), SKAction.rotate(byAngle: -CGFloat(Double.pi)+startingRads*2, duration: rotationLen)]))
        bazooka?.run(SKAction.rotate(byAngle: startingRads, duration: 0))
        rotationStarted = CFAbsoluteTimeGetCurrent()
        bazooka?.run(rotation)
        
        bazookaTapRegion = SKSpriteNode(color: SKColor.white, size: CGSize(width: 275, height: 325))
        bazookaTapRegion?.position = bazookaPos!
        bazookaTapRegion?.zPosition = 3
        bazookaTapRegion?.alpha = 0.001
        bazookaTapRegion?.name = "bazookaTapRegion"
        addChild(bazookaTapRegion!)
    }
    
    func fireBazooka(){
        
        let pauseTime:TimeInterval = 0.5
        
        if bazooka?.alpha != 1.0{
            return
        }
        bazooka?.alpha = 0.5
        let currentRotation = CGFloat(bazooka!.zRotation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pauseTime, execute: { [weak self] in
            self?.bazooka?.alpha = 1.0
        })
        
        let projectile = SKSpriteNode(imageNamed: "bazooka-projectile")
        projectile.size = CGSize(width: 98, height: 64)
        let xPos = bazookaPos?.x
        let yPos = bazookaPos?.y
        projectile.position = CGPoint(x: xPos!, y: yPos!)
        addChild(projectile)
        
        let dy = -sin(currentRotation)*2000
        let dx = -cos(currentRotation)*2000
        projectile.run(SKAction.rotate(toAngle: currentRotation, duration: 0))
        projectile.run(SKAction.moveBy(x: dx, y: dy, duration: 1.5))
    }
}
