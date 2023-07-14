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
    func loadImage(url: String, width: Float, height: Float) {
        
        guard let url = URL(string: url) else {
            print("Error loading image for \(url)")
            return
        }
        // Will be 2.0 on 6/7/8 and 3.0 on 6+/7+/8+ or later
        let scale = UIScreen.main.scale
        // Thumbnail will bounds to (200,200) points
        let thumbnailSize = CGSize(width: 200 * scale, height: 200 * scale)
        
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
}

extension String {
    
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
