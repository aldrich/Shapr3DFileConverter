//
//  DocumentTableViewCell.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {

	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
	static var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return df
	}()
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func configureWith(_ file: Base3DFormat) {
		
		guard let created = file.created,
			let _ = file.derivedFormats,
			let thumbnail = file.imageThumbnail else {
				fatalError("missing values for required properties")
		}
		
		headerLabel?.text = file.filename
		
		let date = DocumentTableViewCell.dateFormatter.string(from: created)
		
		var formatProgress = [String: Float]()
		// get all the formats stored, and their progress
		file.derivedFormats?.forEach({ (df) in
			if let df = df as? Derived3DFormat  {
				formatProgress[df.fileExtension!] = df.convertProgress
			}
		})
		
		// get the first one not 1.
		let firstKV = formatProgress.filter { $0.value < 1 }.first
		
		var progressStr: String = ""
		
		if let firstKV = firstKV {
			progressStr = String(format: "converting %@ - %0.1f%%",
								 firstKV.key,
								 firstKV.value * 100.0)
		} else {
			let formats = file.availableFormats
			if formats.count > 0 {
				progressStr = String(format: "%@ +%d format(s)", date, formats.count)
			} else {
				progressStr = String(format: "%@", date)
			}
		}
		
		detailLabel?.text = progressStr
		imageView?.image = thumbnail.scaledImage
	}
}
