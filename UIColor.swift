//
//  UIColor.swift
//  react-native-legit-video-trimmer
//
//  Created by Andrii Novoselskyi on 28.08.2020.
//

import Foundation

extension UIColor {
    
    convenience init?(string: String?) {
        guard let string = string else { return nil }
        self.init(string: string)
    }
    
    convenience init?(string: String) {
        var str = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard str.count > 0 else { return nil }
        
        if str.hasPrefix("#") {
            str.remove(at: str.startIndex)
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: str).scanHexInt32(&rgbValue)
        
        switch str.count {
        case 6: // "RRGGBB"
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        case 8: // "AARRGGBB"
            self.init(
                red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
                alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            )
        default:
            return nil
        }
    }    
}
