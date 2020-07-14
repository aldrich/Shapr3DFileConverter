//
//  UnitUtilities.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

public struct UnitUtilities {
	
	static var byteCountFormatter: ByteCountFormatter = {
		let bcf = ByteCountFormatter()
		// configure...
		bcf.countStyle = .file
		bcf.includesUnit = true
		bcf.allowedUnits = [.useKB, .useMB]
		return bcf
	}()
	
}
