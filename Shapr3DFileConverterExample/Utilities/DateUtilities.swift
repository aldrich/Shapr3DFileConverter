//
//  DateUtilities.swift
//  Shapr3DFileConverterExample
//
//  Created by Aldrich Co on 7/12/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

class DateUtilities {
	
	static var dateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.dateFormat = "MMM d, h:mm a"
		return df
	}()
}
