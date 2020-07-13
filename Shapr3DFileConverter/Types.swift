//
//  Types.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import CoreData

public enum ShaprOutputFormat: String {
	case shapr = "SHAPR"
	case step = "STEP"
	case stl = "STL"
	case obj = "OBJ"
}

// we'll make the core data models subscribe to them

public protocol BaseFormat {
	var id: UUID? { get set }
	var created: Date? { get set }
	var data: Data? { get set }
	var filename: String? { get set }
	var imageFull: Data? { get set }
	var imageThumbnail: Data? { get set }
	var size: Int32 { get set }
	
	var derivedFormats: NSSet? { get set }
}

public protocol DerivedFormat {
	var id: UUID? { get set }
	var convertProgress: Float { get set }
	var created: Date? { get set }
	var data: Data? { get set }
	var fileExtension: String? { get set }
	var size: Int32 { get set }
}
