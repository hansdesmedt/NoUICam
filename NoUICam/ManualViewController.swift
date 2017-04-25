//
//  ManualViewController.swift
//  NoUICam
//
//  Created by Hans De Smedt on 25/04/2017.
//
//

import UIKit
import AVFoundation

class ManualViewController: UIViewController {

    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        if captureDevice != nil {
            print("Capture device found")
            beginSession()
        }
    }
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()

                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                    //
                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, iso: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            } catch {
                print("error updateDeviceSettings")
            }
        }
    }
    
    func touchPercent(touch: UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.main.bounds.size
        
        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPoint.zero
        
        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.location(in: self.view).x / screenSize.width
        touchPer.y = touch.location(in: self.view).y / screenSize.height
        
        // Return the populated CGPoint
        return touchPer
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPer = touchPercent(touch: touch as UITouch )
            //focusTo(Float(touchPer.x))
            updateDeviceSettings(focusValue: Float(touchPer.x), isoValue: Float(touchPer.y))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPer = touchPercent(touch: touch as UITouch )
            //focusTo(Float(touchPer.x))
            updateDeviceSettings(focusValue: Float(touchPer.x), isoValue: Float(touchPer.y))
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .locked
                device.unlockForConfiguration()
            } catch {
                print("error configureDevice")
            }
        }
    }
    
    func beginSession() {
        configureDevice()
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch {
            print("error beginSession")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        if let previewLayer = previewLayer {
            self.view.layer.addSublayer(previewLayer)
            previewLayer.frame = self.view.layer.frame
            captureSession.startRunning()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let previewLayer = previewLayer {
            previewLayer.frame = view.frame
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func toggleTorch(on: Bool) {
        if let captureDevice = captureDevice, captureDevice.hasTorch {
            do {
                try captureDevice.lockForConfiguration()
                
                if on == true {
                    captureDevice.torchMode = .on
                } else {
                    captureDevice.torchMode = .off
                }
                
                try captureDevice.setTorchModeOnWithLevel(1)
                
                captureDevice.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if let captureDevice = captureDevice {
                switch captureDevice.torchMode {
                case .on:
                    toggleTorch(on: false)
                case .off:
                    toggleTorch(on: true)
                default:
                    break
                }
            }
        }
    }
}
