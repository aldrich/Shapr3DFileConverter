//
//  FontUtilities.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

class FontUtilities {
	static func roundedFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
		let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
		let font: UIFont
		
		if #available(iOS 13.0, *) {
			if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
				font = UIFont(descriptor: descriptor, size: fontSize)
			} else {
				font = systemFont
			}
		} else {
			font = systemFont
		}
		
		return font
	}
}
