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
	
	// This is the function that does the fake conversion of an input Shapr file
	// and sends regular reports of its progress that can be displayed on the UI
	public func convert(_ input: Data, to type: ShaprOutputFormat,
						callback: @escaping ((ConvertProgress) -> Void)) {
		
		// this is the base (divisor) of the eventual % amount
		let totalAmount = 1000
		
		let progressPerTick = 200 // each tick adds a random progress to total,
		// 1..progressBase
		
		// each tick, will compute a random delay (measured in tenths of a second)
		// to be used as the delay between ticks
		let delayTenthsBase: Int = 4 // make it go from 1..base
		
		var counter = 0
		
		var totalSecs = Double(0)
		
		while counter < totalAmount {
			let delay = 1 + Int(arc4random()) % delayTenthsBase
			counter += (1 + Int(arc4random()) % progressPerTick)
			totalSecs += Double(delay) / 10.0
			
			let nextCounter = counter
			
			let dispatchTime = DispatchTime.now() + totalSecs
			DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
				
				let value = Float(nextCounter) / Float(totalAmount)
				
				if value < 1 {
					callback(.progress(value))
				} else {
					let data = Data(count: input.count)
					callback(.completed(data: data))
				}
			}
		}
	}
	
	private func delay(bySeconds seconds: Double,
					   closure: @escaping () -> Void) {
		
		let dispatchTime = DispatchTime.now() + seconds
		DispatchQueue.main
			.asyncAfter(deadline: dispatchTime, execute: closure)
	}
	
}
