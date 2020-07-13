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


class ImageUtilities {
	
	struct Constants {

		// these are the names of the images included in the main assets bundle
		static let possibleImages = [
			"burden",
			"khaprenko",
			"meiying",
			"pat-kay",
			"patrick-ryan",
			"pawel-czerwinski",
			"pawel-czerwinski-2",
			"peter-nguyen",
			"ren-ran",
			"s-s",
			"samsomfotos",
			"samuel-zeller",
			"spencer-davis",
			"spratt",
			"swan-leroi",
			"t-h-chia",
			"tyler-casey",
			"vince-russell",
			"william-warby",
			"willian-justen-de-vasconcellos",
			"yuiizaa-september",
			"yuriy-garnaev",
		]
	}
	
	static func imageData(hashValue: Int, thumb: Bool = false) -> Data? {
		
		// arbitrary based on filename
		let index = abs(hashValue) % Constants.possibleImages.count
		let imageName = Constants.possibleImages[index]
		
		let fullName = "\(imageName)-full"
		let thumbName = "\(imageName)-thumb"
		
		let name = thumb ? thumbName : fullName
		var image = UIImage(named: name)
		
		if thumb {
			image = image?.makeRounded(radius: 4)
		}
		
		return image?.pngData()
	}
}

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
