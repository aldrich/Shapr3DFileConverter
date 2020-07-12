//
//  Models.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

public class ShaprFile {
	
	public var id: UUID
	
	public var filename: String
	
	public var size: Int32
	
	public var created: Date
	
	public var image: UIImage?
	
	public var thumbnail: UIImage?
	
	public var data: Data?
	
	public var derivedFormats: [DerivedFileFormat]
	
	public init(id: UUID,
				filename: String,
				size: Int32,
				created: Date,
				image: UIImage?,
				thumbnail: UIImage?,
				data: Data?,
				derivedFormats: [DerivedFileFormat]) {
		
		self.id = id
		self.filename = filename
		self.size = size
		self.created = created
		self.image = image
		self.thumbnail = thumbnail
		self.data = data
		self.derivedFormats = derivedFormats
	}
}
