//
//  LensFlare.swift
//  Flare Eyes
//
//  Created by Serge-Olivier Amega on 3/6/16.
//  Copyright © 2016 Nexiosoft. All rights reserved.
//

import UIKit

let kFlareMain2Name = "flarMain_2_c_D"
let kBokeh2Name = "bokeh_2_c_D"

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
    let bokehImage_a : UIImage
    
    override init() {
        mainFlareImage = scaleImage(UIImage(named: kFlareMain2Name)!, sx: 5.0, sy: 2.5)
        bokehImage_a = scaleImage(UIImage(named: kBokeh2Name)!, sx: 0.3, sy: 0.3)
        super.init()
    }
    
    private override func drawLensFlare(point: CGPoint, inRect rect: CGRect) {
        
        let pt_main = CGPointMake(point.x - mainFlareImage.size.width/2, point.y - mainFlareImage.size.height/2)
        
        let pt_an = diagFactor(point, factor: -1.0, rect: rect)
        let pt_a = CGPoint(x: pt_an.x - bokehImage_a.size.width/2, y: pt_an.y - bokehImage_a.size.width/2)
        
        mainFlareImage.drawAtPoint(pt_main, blendMode: CGBlendMode.Screen, alpha: 1.0)
        bokehImage_a.drawAtPoint(pt_a, blendMode: CGBlendMode.Screen, alpha: 0.2)
    }
}

//function is broken if factor != 2.0
//TODO fix
private func scaleImage(image: UIImage, sx : CGFloat, sy : CGFloat) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: image.size.width * sx, height: image.size.height * sy)
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * sx , image.size.height * sy))
    image.drawInRect(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
    
}

private func +(l : CGPoint, r : CGPoint) -> CGPoint {
    return CGPoint(x: l.x+r.x, y: l.y+r.y)
}

private func *(f : CGFloat, pt : CGPoint) -> CGPoint {
    return CGPoint(x: f*pt.x, y: f*pt.y)
}

private func diagFactor(pt : CGPoint, factor : CGFloat, rect : CGRect) -> CGPoint {
    let r = CGPoint(x: rect.width, y: rect.height)
    return (factor * (pt + -0.5*r)) + 0.5*r
}