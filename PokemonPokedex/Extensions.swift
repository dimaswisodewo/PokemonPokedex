//
//  ImageLoaderManager.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func loadImage(url: String) {
        
        guard let url = URL(string: url) else {
            print("Error loading image for \(url)")
            return
        }
        
        self.sd_setImage(with: url)
    }
    
    // To save CPU && Memory for large images
    func loadImage(url: String, width: CGFloat, height: CGFloat) {
        
        guard let url = URL(string: url) else {
            print("Error loading image for \(url)")
            return
        }
        // Will be 2.0 on 6/7/8 and 3.0 on 6+/7+/8+ or later
        let scale = UIScreen.main.scale
        // Thumbnail will bounds to (200,200) points
        let thumbnailSize = CGSize(width: width * scale, height: width * scale)
        
        self.sd_setImage(
            with: url,
            placeholderImage: nil,
            context: [.imageThumbnailPixelSize : thumbnailSize])
    }
    
}

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
    }
    
}

extension UIColor {
    
    static func getPredefinedColorName(color: UIColor) -> String {
        
        let greenColor = UIColor(named: "PrimaryGreen")!
        let blueColor = UIColor(named: "PrimaryBlue")!
        let yellowColor = UIColor(named: "PrimaryYellow")!
        let redColor = UIColor(named: "PrimaryRed")!
        let purpleColor = UIColor(named: "PrimaryPurple")!
        let brownColor = UIColor(named: "PrimaryBrown")!
        let whiteColor = UIColor(named: "PrimaryWhite")!
        let pinkColor = UIColor(named: "PrimaryPink")!
        let grayColor = UIColor.gray
        let blackColor = UIColor(named: "PrimaryBlack")!
        
        switch color.cgColor {
        case greenColor.cgColor:
            return "green"
        case blueColor.cgColor:
            return "blue"
        case yellowColor.cgColor:
            return "yellow"
        case redColor.cgColor:
            return "red"
        case purpleColor.cgColor:
            return "purple"
        case brownColor.cgColor:
            return "brown"
        case whiteColor.cgColor:
            return "white"
        case pinkColor.cgColor:
            return "pink"
        case grayColor.cgColor:
            return "gray"
        case blackColor.cgColor:
            return "black"
        default:
            return "gray"
        }
    }
    
    static func getPredefinedColor(name: String) -> UIColor {
        
        var color = UIColor.lightGray
        
        switch name {
        case "green":
            color = UIColor(named: "PrimaryGreen")!
        case "blue":
            color = UIColor(named: "PrimaryBlue")!
        case "yellow":
            color = UIColor(named: "PrimaryYellow")!
        case "red":
            color = UIColor(named: "PrimaryRed")!
        case "purple":
            color = UIColor(named: "PrimaryPurple")!
        case "brown":
            color = UIColor(named: "PrimaryBrown")!
        case "white":
            color = UIColor(named: "PrimaryGrey")!
        case "pink":
            color = UIColor(named: "PrimaryPink")!
        case "gray":
            color = UIColor.gray
        case "black":
            color = UIColor(named: "PrimaryBlack")!
        default:
            print("Color not found: \(name)")
            break
        }
        
        return color
    }
    
}

extension UIImage {
    
    var base64: String? {
        self.pngData()?.base64EncodedString()
    }
    
    // This method creates an image of a view
    convenience init?(view: UIView) {

        // Based on https://stackoverflow.com/a/41288197/1118398
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
        }

        if let cgImage = image.cgImage {
            self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        } else {
            return nil
        }
    }
}

extension String {
    
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
