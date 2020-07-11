//
//  DerivedFileFormat.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import UIKit

public class DerivedFileFormat: NSObject {
	
	public var id: UUID
	
	public var size: Int32
	
	public var created: Date
	
	public var fileExtension: FileExtension
	
	public var data: Data?
	
	@objc dynamic public var convertProgress: CGFloat
	
	public init(id: UUID,
				size: Int32,
				created: Date,
				fileExtension: FileExtension,
				data: Data?,
				convertProgress: CGFloat) {
		
		self.id = id
		self.size = size
		self.created = created
		self.fileExtension = fileExtension
		self.data = data
		self.convertProgress = convertProgress
	}
}
