//
//  ShaprDocument.swift
//  Shaper3DImport
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import UIKit

class ShaprDocument: UIDocument {
	
	var data: Data?
	
	override func contents(forType typeName: String) throws -> Any {
		guard let data = data else {
			return Data()
		}
		return try NSKeyedArchiver.archivedData(withRootObject:data,
												requiringSecureCoding: true)
	}
	
	override func load(fromContents contents: Any, ofType typeName:
		String?) throws {
		guard let data = contents as? Data else { return }
		self.data = data
	}
}
