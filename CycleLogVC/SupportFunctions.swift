//
//  SupportFunctions.swift
//  CycleLogVC
//
//  Created by Hannes Schaletzky on 07.05.20.
//  Copyright © 2020 Hannes Schaletzky. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SystemConfiguration

struct ImageRotation {
    static let BackPortrait = "BackPortrait"
    static let BackLandscape = "BackLandscape"
    static let FrontPortait = "FrontPortait"
    static let FrontLandscape = "FrontLandscape"
}



protocol Utilities {}
extension NSObject: Utilities {
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }

    var currentReachabilityStatus: ReachabilityStatus {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }

        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
}


func getDistanceBetweenLogs(log1:Log, log2:Log) -> Int {
    
    let coordinate1 = CLLocation(latitude: log1.lat, longitude: log1.lon)
    let coordinate2 = CLLocation(latitude: log2.lat, longitude: log2.lon)
    
    //returns in meters
    let distanceInMeters = coordinate1.distance(from: coordinate2) // result is in meters
    return Int(distanceInMeters)
}






func getImageOrientationDefinitionFor(image:UIImage) -> String {
    
    let w = image.size.width    //width
    let h = image.size.height   //height
    
    /*                                                 afer retrieve, how to rotate?
    w: 3024.0 - h:4032.0   back - portrait     ->  BP  ->
    w: 4032.0 - h:3024.0   back - landscape    ->  BL  ->
    w: 2320.0 - h:3088.0   front - portrait    ->  FP  ->
    w: 3088.0 - h:2320.0   front - landscape   ->  FL  ->
    */
    
    if (w == 3024 && h == 4032) {
        return ImageRotation.BackPortrait
    }
    else if (w == 4032 && h == 3024) {
        return ImageRotation.BackLandscape
    }
    else if (w == 2320 && h == 3088) {
        return ImageRotation.FrontPortait
    }
    else if (w == 3088 && h == 2320) {
        return ImageRotation.FrontLandscape
    }
    return ""
    
}

func getRotationValueFor(orientationDef:String) -> CGFloat {
    
    /*
     
     //rotate 90 degrees
     myImageView.transform = CGAffineTransform(rotationAngle: .pi / 2)
     //rotate 180 degrees
     myImageView.transform = CGAffineTransform(rotationAngle: .pi)
     //rotate 270 degrees
     myImageView.transform = CGAffineTransform(rotationAngle: .pi * 1.5)
     
     */
    
    var val = 0.0
    
    if (orientationDef == ImageRotation.BackPortrait) {
        //90° clockwise
         val = Double.pi/2
    }
    else if (orientationDef == ImageRotation.BackLandscape) {
        //NO ROTATION NEEDED
        val = 0
    }
    else if (orientationDef == ImageRotation.FrontPortait) {
        //90° clockwise
        val = Double.pi/2
    }
    else if (orientationDef == ImageRotation.FrontLandscape) {
        //180°
        val = Double.pi
    }
    
    return CGFloat(val)
}





extension UIImage {
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}











public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    
}



public extension String {

    /*
    let text = "www.stackoverflow.com"
    let at = text.character(3) // .
    let range = text.substring(0..<3) // www
    let from = text.substring(from: 4) // stackoverflow.com
    let to = text.substring(to: 16) // www.stackoverflow
    let between = text.between(".", ".") // stackoverflow
    let substringToLastIndexOfChar = text.lastIndexOfCharacter(".") // 17
    */
    
    //right is the first encountered string after left
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            , leftRange.upperBound <= rightRange.lowerBound
            else { return nil }

        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }

    var length: Int {
        get {
            return self.count
        }
    }

    func substring(to : Int) -> String {
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[...toIndex])
    }

    func substring(from : Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }

    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }

    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }

    func lastIndexOfCharacter(_ c: Character) -> Int? {
        return range(of: String(c), options: .backwards)?.lowerBound.encodedOffset
    }
}



extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}


extension String {
     struct NumFormatter {
         static let instance = NumberFormatter()
     }

     var doubleValue: Double? {
         return NumFormatter.instance.number(from: self)?.doubleValue
     }

     var integerValue: Int? {
         return NumFormatter.instance.number(from: self)?.intValue
     }
}
