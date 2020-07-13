//
//  ConvertQueue.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

public typealias ProgressInfo = (id: UUID, created: Date?, progress: Float, data: Data?)

public protocol ConvertQueue {
	
	func add(id: UUID, data: Data, format: ShaprOutputFormat,
			 update: @escaping (ProgressInfo) -> Void)
}

public class ConversionQueue: ConvertQueue {
	
	private let converter: Converter
	
	private var queue = [UUID: ConvertProgress]()
	
	public init(converter: Converter) {
		self.converter = converter
	}
	
	public func add(id: UUID, data: Data, format: ShaprOutputFormat,
					update: @escaping (ProgressInfo) -> Void) {
		
		converter.convert(data, to: format) { [weak self] newProgress in
			
			self?.queue[id] = newProgress

			var created: Date?
			var progress: Float = 0
			var data: Data?

			switch newProgress {
			case let .completed(outputData):
				created = Date()
				progress = 1.0
				data = outputData
				break
			case let .progress(prog):
				progress = prog
			case let .error(message):
				print(message) // TODO: should delete?
			}

			update((id, created, progress, data))
		}
	}	
}
