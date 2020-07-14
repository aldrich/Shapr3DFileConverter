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
		// I got these images from Unsplash
		static let unsplashImages = [
			"chris-becker-52648-unsplash",
			"christian-holzinger-CUY_YHhCFl4",
			"christian-schrader-1204549-unsplash",
			"dmitri-popov-173676-unsplash",
			"ibrahim-mushan-qnjKufYqIIE",
			"jack-anstey-XVoyX7l9ocY",
			"jacob-ufkes-1vTFoSyWyFQ",
			"james-donovan-OqBAhbdRsFg",
			"jay-castor-7AcMUSYRZpU-unsplash",
			"jelle-plevier-1364756-unsplash",
			"jesse-orrico-232823-unsplash",
			"john-purakal-1189719-unsplash",
			"joshua-sortino-xZqr8WtYEJ0",
			"julien-moreau-83192-unsplash",
			"kyaw-tun-lK3x9PCj0j4-unsplash",
			"lai-man-nung-1205465-unsplash",
			"marcelo-cidrack-1514307-unsplash",
			"meiying-ng-OrwkD-iWgqg-unsplash",
			"mitchell-luo-UiSU4AUcQEA-unsplash",
			"nathan-anderson-111801",
			"pascal-debrunner-1471182-unsplash",
			"samsomfotos-vddccTqwal8",
			"t-h-chia-1485987-unsplash",
			"tyler-casey-1474093-unsplash",
			"willian-justen de vasconcellos-cNagAGEok9k",
			"yuriy-garnaev-HBGl-1uwgSY-unsplash",
		]
	}
	
	static func imageData(hashValue: Int, thumb: Bool = false) -> Data? {
		
		let imageNames = (1...14).map { "image-\($0)" } + Constants.unsplashImages
		
		// arbitrary based on filename
		let index = abs(hashValue) % imageNames.count
		let imageName = imageNames[index]
		
		let fullName = "\(imageName)-full"
		let thumbName = "\(imageName)-thumb"
		
		let name = thumb ? thumbName : fullName
		var image = UIImage(named: name)
		
		if thumb {
			image = image?.makeRounded(radius: 5)
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
