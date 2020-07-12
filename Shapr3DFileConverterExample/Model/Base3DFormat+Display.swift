//
//  Base3DFormat+Display.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation
import Shapr3DFileConverter

extension Base3DFormat {
	
	var available3DFormats: [Derived3DFormat] {
		derivedFormats?
			.allObjects
			.compactMap { $0 as? Derived3DFormat }
			.filter { $0.convertProgress >= 1 }
			?? []
	}
	
	var availableFormatStrs: [String] {
		["shapr"] + available3DFormats.compactMap { $0.fileExtension }.sorted()
	}
	
	var availableFormats: [ShaprOutputFormat] {
		availableFormatStrs.compactMap { ShaprOutputFormat(rawValue: $0) }
	}
}
