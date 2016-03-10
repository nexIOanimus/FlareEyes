//
//  ImageProcessor.swift
//  Flare Eyes
//
//  Created by Serge-Olivier Amega on 3/4/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit
import ImageIO

class ImageProcessor: NSObject {
    
    var setImgFunc : ((UIImage) -> Void)?
    var lensFlare = LensFlare.getLensFlareWithName("default")
    
    override init() {
        super.init()
    }
    
    //TODO : change to array of CGPoints for more speed
    func drawLensFlare(image : UIImage, atPoint point : CGPoint) -> UIImage? {

        
        let rect = CGRectMake(0, 0, image.size.width, image.size.height)
        
        let actualPoint = CGPointMake(point.x, rect.height/2 - (point.y - rect.height/2))
        
        //calculate points for lens flare
        
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        //clip
        CGContextClipToRect(context, rect)
        
        image.drawInRect(rect)
        
        lensFlare.drawLensFlare(actualPoint, inRect: rect)
        
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return ret
    }
    
    func processImage(image :UIImage) {
        
        UIGraphicsBeginImageContext(image.size)
        
        let context = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        /*
        A = [[a,b,0] [c,d,0] [tx,ty,1]]
        x = [x_1,x_2,1]
        T : x |-> Ax
        */
        //MATH 2940 Linear Algebra FTW!!!
        //rotate 90º and flip horiz and translate back
        CGContextConcatCTM(context, CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: image.size.width/2, ty: image.size.height/2))
        //translate to origin
        CGContextConcatCTM(context, CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: -image.size.width/2, ty: -image.size.height/2))
        
        
        //CGContextTranslateCTM(context, image.size.width/2, image.size.height/2)
        //CGContextRotateCTM(context, CGFloat(M_PI_2))
        //CGContextTranslateCTM(context, -image.size.width/2, -image.size.height/2)
        
        image.drawInRect(rect)
        
        var rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        //apply fx
        let ciContext = CIContext()
        let contextOptions = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: ciContext, options: contextOptions)
        
        guard let ciimg = CIImage(image: rotatedImage) else {
            print("fail processImage")
            return
        }
        
        if let features = (detector.featuresInImage(ciimg) as? [CIFaceFeature]) {
            for f in features {
                if f.hasLeftEyePosition {
                    rotatedImage = drawLensFlare(rotatedImage, atPoint: CGPointMake(f.leftEyePosition.x, f.leftEyePosition.y))
                }
                
                if f.hasRightEyePosition {
                    rotatedImage = drawLensFlare(rotatedImage, atPoint: CGPointMake(f.rightEyePosition.x, f.rightEyePosition.y))
                }
            }
        }
        
        setImgFunc?(rotatedImage)
    }
}
