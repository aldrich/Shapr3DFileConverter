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
		derivedFormats?.allObjects.compactMap {
			$0 as? Derived3DFormat
		} ?? []
	}
	
	var availableFormatStrs: [String] {
		let ret = available3DFormats.compactMap { $0.fileExtension } + [".shapr"]
		return ret.sorted()
	}
	
	var availableFormats: [ShaprOutputFormat] {
		return availableFormatStrs.compactMap { ShaprOutputFormat(rawValue: $0) }
	}
}
