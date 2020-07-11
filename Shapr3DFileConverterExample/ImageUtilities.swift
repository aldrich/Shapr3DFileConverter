//
//  ImageUtilities.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
	
	func makeRounded(radius: CGFloat) -> UIImage {
		let imageLayer = CALayer()
		
		let scale = UIScreen.main.scale
		let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
		
		imageLayer.frame = CGRect(x: 0, y: 0,
								  width: size.width,
								  height: size.height)
		imageLayer.contents = cgImage
		imageLayer.masksToBounds = true
		imageLayer.cornerRadius = radius
		
		UIGraphicsBeginImageContext(size)
		imageLayer.render(in: UIGraphicsGetCurrentContext()!)
		let roundedImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return roundedImage
	}
	
	
}

extension Data {
	var scaledImage: UIImage? {
		return UIImage(data: self,
					   scale: UIScreen.main.scale)
	}
}
