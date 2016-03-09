//
//  ViewController.swift
//  Flare Eyes
//
//  Created by Serge-Olivier Amega on 2/29/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit
import AVFoundation

class AVSystem : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession : AVCaptureSession?
    var updateImgFunc : ((UIImage) -> Void)?
    
    override init() {
    }
    
    func checkAuth() {
        let auth = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if auth == AVAuthorizationStatus.NotDetermined {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
        }
    }
    
    func startCapture(imgFunc : ((UIImage) -> Void) ) {
        
        updateImgFunc = imgFunc
        checkAuth()
        
        //make an AVCaptureSession
        //make an AVCaptureDevice for type of input
        //make an AVCaptureDeviceInput for device
        //make AVCaptureVideoDataOutput to make video frames
        //implement delegate for the AVCaptureVideoDataOutput
        
        //make an AVCaptureSession
        self.captureSession = AVCaptureSession()
        guard let cSession = self.captureSession else {
            return;
        }
        cSession.sessionPreset = AVCaptureSessionPresetMedium
        
        //make an AVCaptureDevice for type of input
        //var captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var captureDevice : AVCaptureDevice?
        
        //scan for input device
        for device in (AVCaptureDevice.devices() as! [AVCaptureDevice]) {
            if (device.hasMediaType(AVMediaTypeVideo) &&
                device.position == .Front) {
                    captureDevice = device
                    break;
            }
        }
        
        //make an AVCaptureDeviceInput
        guard let camInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("AVCaptureDeviceInput(device:) FAIL")
            return
        }
        
        //make AVCaptureVideoDataOutput
        let vidOutput = AVCaptureVideoDataOutput()
        vidOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_32BGRA)]
        
        let queue = dispatch_queue_create("MyQueue", nil)
        vidOutput.setSampleBufferDelegate(self, queue: queue)
        
        //add inputs
        if ( cSession.canAddInput(camInput) &&
            cSession.canAddOutput(vidOutput)) {
                cSession.addInput(camInput)
                cSession.addOutput(vidOutput)
        }
        
        cSession.startRunning()
        print("running")
    }
    
    func stopCapture() {
        self.captureSession?.stopRunning()
    }
    
    func uiImageFromSampleBuffer(sampleBuffer: CMSampleBufferRef) -> UIImage? {
        
        guard let cvBuffer : CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(cvBuffer, 0)
        
        let width = CVPixelBufferGetWidth(cvBuffer)
        let height = CVPixelBufferGetHeight(cvBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(cvBuffer)
        let bytesPerPixel = bytesPerRow/width
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let baseAddress = CVPixelBufferGetBaseAddress(cvBuffer)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue )
        let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        let quartz = CGBitmapContextCreateImage(context)
        CVPixelBufferUnlockBaseAddress(cvBuffer,0);
        
        return UIImage(CGImage: quartz!)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
        fromConnection connection: AVCaptureConnection!) {
            updateImgFunc?(self.uiImageFromSampleBuffer(sampleBuffer)!)
    }
    
}

class ViewController: UIViewController {
    
    var processor : ImageProcessor = ImageProcessor()
    
    @IBOutlet weak var imageView: UIImageView!
    
    let avSystem : AVSystem = AVSystem()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.processor.setImgFunc = {(img:UIImage)->Void in
            dispatch_async( dispatch_get_main_queue()) {
                self.imageView.image = img
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startCapture(sender: AnyObject) {
        avSystem.startCapture({(img : UIImage) -> Void in
            self.processor.processImage(img)
        })
    }
}

