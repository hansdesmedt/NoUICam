//
//  ViewController.swift
//  NoUICam
//
//  Created by Hans De Smedt on 25/04/2017.
//
//

import UIKit
import FastttCamera

class ViewController: UIViewController, FastttCameraDelegate {
    
    let fastttCamera = FastttCamera()

    override func viewDidLoad() {
        super.viewDidLoad()
        fastttCamera.delegate = self
        self.fastttAddChildViewController(fastttCamera)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            switch fastttCamera.cameraTorchMode {
            case .on:
                fastttCamera.cameraTorchMode = .off
            case .off:
                fastttCamera.cameraTorchMode = .on
            default:
                break
            }
        }
    }
}
