//
//  Models.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

public enum FileExtension: String {
	case step, stl, obj
}

public struct ShaprFile {
	public let filename: String
	public let size: Int32
	public let created: Date
	
	public let image: UIImage?
	public let thumbnail: UIImage?
	
	public let derivedFormats: [DerivedFileFormat]
	
	public init(filename: String, size: Int32, created: Date, image: UIImage?, thumbnail: UIImage?, derivedFormats: [DerivedFileFormat]) {
		
		self.filename = filename
		self.size = size
		self.created = created
		self.image = image
		self.thumbnail = thumbnail
		self.derivedFormats = derivedFormats
	}
}

public struct DerivedFileFormat: Hashable {
	public let size: Int32
	public let created: Date
	public let fileExtension: FileExtension
	public let convertProgress: CGFloat // 0..1
	
	public init(size: Int32, created: Date, fileExtension: FileExtension,
				convertProgress: CGFloat) {
		self.size = size
		self.created = created
		self.fileExtension = fileExtension
		self.convertProgress = convertProgress
	}
}
