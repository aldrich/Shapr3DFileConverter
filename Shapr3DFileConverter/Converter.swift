//
//  Converter.swift
//  Shapr3DFileConverter
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import Foundation

public enum ConvertProgress {
	case progress(_ progress: Float)
	case completed(data: Data)
	case error(message: String)
}

// takes a shapr file
public class Converter {
	
	public init() {}
	
	// asynchronously call progress
	public func convert(_ input: Data, to type: ShaprOutputFormat,
						callback: @escaping ((ConvertProgress) -> Void)) {
		
		let queue = DispatchQueue(label: "conversion", qos: .userInitiated)
		let total = 1000
		
		let progressBase = 120 // each tick adds a random progress to total,
		// 1..progressBase
		
		// each tick, will compute a random delay (in tenths of a second)
		// to use as the delay
		let delayTenthsBase: Int = 4 // make it go from 1..base
		
		var counter = 0
		var totalSecs = Double(0)
		
		queue.async { [weak self] in
			while counter < total {
				let delay = 1 + Int(arc4random()) % delayTenthsBase
				totalSecs += Double(delay) / 10.0
				counter += (1 + Int(arc4random()) % progressBase)
				let nextCounter = counter

				self?.delay(bySeconds: totalSecs) {

					let value = Float(nextCounter) / Float(total)

					if value < 1 {
						callback(.progress(value))
					} else {
						callback(.completed(data: Data()))
					}
				}
			}
		}
	}
	
	func delay(bySeconds seconds: Double,
			   dispatchLevel: DispatchLevel = .main,
			   closure: @escaping () -> Void) {
		
		let dispatchTime = DispatchTime.now() + seconds
		dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
	}
	
	enum DispatchLevel {
		case main, userInteractive, userInitiated, utility, background
		var dispatchQueue: DispatchQueue {
			switch self {
			case .main:                 return DispatchQueue.main
			case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
			case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
			case .utility:              return DispatchQueue.global(qos: .utility)
			case .background:           return DispatchQueue.global(qos: .background)
			}
		}
	}
}
