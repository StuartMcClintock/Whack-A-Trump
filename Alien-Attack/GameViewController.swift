//
//  GameViewController.swift
//  Alien-Attack
//
//  Created by Stuart McClintock on 5/5/20.
//  Copyright © 2020 Stuart McClintock. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var del: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = UIApplication.shared.delegate as? AppDelegate
        
        del.numGold = UserDefaults.standard.integer(forKey: "numGold")
        del.numMercs = UserDefaults.standard.integer(forKey: "numMercs")
        del.buildCoinFrames()
        
        
        print(UIScreen.main.bounds)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "IntroScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                if UIDevice.current.model == "iPad"{
                    scene.scaleMode = .fill
                }
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
