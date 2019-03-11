//
//  ViewController.swift
//  Example
//
//  Created by Tatsuya Tanaka on 2019/02/11.
//  Copyright © 2019 Tatsuya Tanaka. All rights reserved.
//

import UIKit
import SceneKit
import VTuberKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet private weak var avatarView: AvatarView!
    var player : AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        avatarView.autoenablesDefaultLighting = true
        avatarView.allowsCameraControl = true
        //avatarView.showsStatistics = true
        avatarView.backgroundColor = UIColor.clear

        do {
            try avatarView.loadModel(withName: "3006073552119103369.vrm")
        } catch {
            print(error)
        }

        setUpScene()
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        let audioPath = URL(fileURLWithPath: Bundle.main.path(forResource: "voice", ofType: "mp3")!)
        player  = try! AVAudioPlayer(contentsOf: audioPath, fileTypeHint: nil)
        player.isMeteringEnabled = true
        player.prepareToPlay()
        player.play()
        player.numberOfLoops = -1
        player.delegate = self
    }

    private func setUpScene() {
        let avatar = avatarView.avatar
        avatar.humanoid.node(for: .leftShoulder)?.eulerAngles = SCNVector3(0, 0, 20.0 * .pi / 180)
        avatar.humanoid.node(for: .rightShoulder)?.eulerAngles = SCNVector3(0, 0, -20.0 * .pi / 180)

        let camera = avatarView.cameraNode
        camera.camera?.fieldOfView = 38
        camera.position.y = 0.8
        camera.eulerAngles.x += 20 * Float.pi / 180
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avatarView.startFaceTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avatarView.stopFaceTracking()
    }

    @IBAction private func didFaceChanged(_ sender: UISegmentedControl) {
        let avatar = avatarView.avatar
        avatar.setBlendShape(value: 0, for: .preset(.joy))
        avatar.setBlendShape(value: 0, for: .preset(.fun))
        avatar.setBlendShape(value: 0, for: .preset(.sorrow))
        avatar.setBlendShape(value: 0, for: .preset(.angry))
        avatar.setBlendShape(value: 0, for: .custom("><"))

        let index = sender.selectedSegmentIndex
        avatarView.isBlinkTrackingEnabled = index == 0
        avatarView.isMouthTrackingEnabled = index != 1 && index != 4

        switch index {
        case 1:
            avatar.setBlendShape(value: 1.0, for: .preset(.joy))
        case 2:
            avatar.setBlendShape(value: 1.0, for: .preset(.fun))
        case 3:
            avatar.setBlendShape(value: 1.0, for: .preset(.sorrow))
        case 4:
            avatar.setBlendShape(value: 1.0, for: .preset(.angry))
        case 5:
            avatar.setBlendShape(value: 1.0, for: .custom("><"))
        default: ()
        }
    }
    
    @IBAction func didMouthChanged(_ sender: Any) {
        update()
    }
    
    @objc func update() {
        let avatar = avatarView.avatar
        avatar.setBlendShape(value: 0, for: .preset(.a))
        avatar.setBlendShape(value: 0, for: .preset(.i))
        avatar.setBlendShape(value: 0, for: .preset(.u))
        avatar.setBlendShape(value: 0, for: .preset(.e))
        avatar.setBlendShape(value: 0, for: .preset(.o))
        
        let iRand = Int.random(in: -2 ... 2)
        
        player?.updateMeters()
        let avg = player!.averagePower(forChannel: 0) + 20.0
        print(avg)
        let vol = avg > 0 ? CGFloat(1.0) : CGFloat(0.0)
        
        if avg > 0 {
            avatar.humanoid.node(for: .neck)?.eulerAngles = SCNVector3(0, 0, Double(iRand) * 0.8 * .pi / 180)
        }
        
        switch iRand {
        case -2:
            avatar.setBlendShape(value: vol, for: .preset(.a))
        case -1:
            avatar.setBlendShape(value: vol, for: .preset(.i))
        case 0:
            avatar.setBlendShape(value: vol, for: .preset(.u))
        case 1:
            avatar.setBlendShape(value: vol, for: .preset(.e))
        case 2:
            avatar.setBlendShape(value: vol, for: .preset(.o))
        default: ()
        }
    }

}

