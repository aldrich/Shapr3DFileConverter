//
//  ConvertQueue.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

public protocol ConvertQueue {
	
	func add(id: UUID, data: Data, format: ShaprOutputFormat,
			 update: @escaping (ConvertProgress) -> Void)
}

public class ConversionQueue: ConvertQueue {
	
	private let converter: Converter
	
	private var queue = [UUID: ConvertProgress]()
	
	public init(converter: Converter) {
		self.converter = converter
	}
	
	public func add(id: UUID, data: Data, format: ShaprOutputFormat,
			 update: @escaping (ConvertProgress) -> Void) {
		
		converter.convert(data, to: format) { [weak self] progress in
			self?.queue[id] = progress
			update(progress)
		}
	}	
}
