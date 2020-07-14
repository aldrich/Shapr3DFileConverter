//
//  ConverterTests.swift
//  Shapr3DFileConverterTests
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import Shapr3DFileConverter

class ConverterTests: XCTestCase {
	
	override func setUpWithError() throws {}
	
	override func tearDownWithError() throws {}
	
	func testConvertWouldFinishWithData() throws {
		
		let expect = expectation(description: "should finish after some time")
		let converter = Converter()
		let data = Data(count: 1024)
		
		converter.convert(data, to: .obj) { progress in
			print(progress)
			switch progress {
			case .completed(let data):
				XCTAssertGreaterThan(data.count, 0, "data should be non-empty")
				expect.fulfill()
			default: break
			}
		}
		
		waitForExpectations(timeout: 10) { (error) in
			print("done.")
		}
	}
	
	func testConvertReturnsIncreasingPartialProgress() throws {
		
		let expect = expectation(description: "should finish after some time")
		let converter = Converter()
		let data = Data(count: 1024)
		
		var progressValue = Float(0)
		
		converter.convert(data, to: .obj) { progress in
			print(progress)
			switch progress {
			case let .progress(value):
				
				XCTAssertGreaterThan(value, progressValue)
				progressValue = value
				
			case .completed: expect.fulfill()
			default: break
			}
		}
		
		waitForExpectations(timeout: 10) { (error) in
			print("done.")
		}
	}
}
