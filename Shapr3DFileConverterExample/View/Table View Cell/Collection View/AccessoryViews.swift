//
//  AccessoryViews.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit
import Shapr3DFileConverter

class ContentCell: UICollectionViewCell {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		layer.cornerRadius = 2
		clipsToBounds = true
	}
	
	@IBOutlet weak var contentLabel: UILabel! {
		didSet {
			contentLabel.textColor = .white
			contentLabel.font = .boldSystemFont(ofSize: 10)
		}
	}
	
	func populate(with format: ShaprOutputFormat) {
		contentLabel.text = format.rawValue
		backgroundColor = format.color
	}
}

extension ShaprOutputFormat {
	var color: UIColor {
		switch self {
		case .obj:
			return UIColor(red: 246/255.0, green: 80/255.0, blue: 88/255.0, alpha: 1)
		case .step:
			return UIColor(red: 251/255.0, green: 222/255.0, blue: 68/255.0, alpha: 1)
		case .stl:
			return UIColor(red: 40/255.0, green: 51/255.0, blue: 74/255.0, alpha: 1)
		default:
			return .black
		}
	}
}
