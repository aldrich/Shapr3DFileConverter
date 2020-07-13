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
	
	var convertedFormats: [Derived3DFormat] {
		derivedFormats?
			.allObjects
			.compactMap { $0 as? Derived3DFormat }
			.filter { $0.convertProgress >= 1 }
			?? []
	}
	
	func availableFormats(includeShapr: Bool = true) -> [ShaprOutputFormat] {
		var ret = convertedFormats
			.compactMap { $0.fileExtension }
			.sorted()
			.compactMap { ShaprOutputFormat(rawValue: $0) }
		if includeShapr {
			ret.insert(.shapr, at: 0)
		}
		return ret
	}
	
	var formatsUndergoingExport: [Derived3DFormat] {
		derivedFormats?.allObjects
			.compactMap { $0 as? Derived3DFormat }
			.filter { $0.convertProgress < 1 }
			?? []
	}
	
	var formatsAvailableForExport: [ShaprOutputFormat] {
		
		let availableFormatsList: [ShaprOutputFormat] = [
			.obj, .step, .stl
		]
		
		// undergoing or completed (progress > 0)
		
		let unavailableOptions = derivedFormats?
			.allObjects
			.compactMap { $0 as? Derived3DFormat }
			.filter { $0.convertProgress > 0 }
			.compactMap { $0.fileExtension }
			.compactMap { ShaprOutputFormat(rawValue: $0) } ?? []
		
		return availableFormatsList.filter {
			!unavailableOptions.contains($0)
		}
	}
}
