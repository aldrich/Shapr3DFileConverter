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
			contentLabel.font = .boldSystemFont(ofSize: 11)
		}
	}
	
	func populate(with format: ShaprOutputFormat) {
		contentLabel.text = format.rawValue
		backgroundColor = format.color
		contentLabel.textColor = format.textColor
	}
}
