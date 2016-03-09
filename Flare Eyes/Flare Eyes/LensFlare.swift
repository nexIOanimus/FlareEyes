//
//  LensFlare.swift
//  Flare Eyes
//
//  Created by Serge-Olivier Amega on 3/6/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

let kFlareMain2Name = "flarMain_2_c_D"

class LensFlare: NSObject {
    func drawLensFlare(point : CGPoint, inRect rect: CGRect) {}
    
    class func getLensFlareWithName(name : String) -> LensFlare {
        switch name {
        case "default" :
            return LensFlareDefault()
        case _:
            return LensFlare()
        }
    }
}

private class LensFlareDefault: LensFlare {
    
    let mainFlareImage : UIImage
    
    
    override init() {
        mainFlareImage = scaleImage(UIImage(named: kFlareMain2Name)!, factor: 2.0)
        super.init()
    }
    
    private override func drawLensFlare(point: CGPoint, inRect rect: CGRect) {
        
        let pt = CGPointMake(point.x - mainFlareImage.size.width/2, point.y - mainFlareImage.size.height/2)
        mainFlareImage.drawAtPoint(pt, blendMode: CGBlendMode.Screen, alpha: 1.0)
        
    }
}

//function is broken if factor != 2.0
//TODO fix
private func scaleImage(image: UIImage, factor: CGFloat) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: image.size.width * factor, height: image.size.height * factor)
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * factor, image.size.height * factor))
    let context = UIGraphicsGetCurrentContext()
    
    //CGContextTranslateCTM(context, image.size.width/8, image.size.height/8)
    CGContextScaleCTM(context, factor, factor)
    CGContextTranslateCTM(context, -image.size.width/2, -image.size.height/2)
    
    image.drawInRect(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
}