//
//  Shapr3DFileConverterTests.swift
//  Shapr3DFileConverterTests
//
//  Created by Aldrich Co on 7/11/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import Shapr3DFileConverter

class Shapr3DFileConverterTests: XCTestCase {
	
	override func setUpWithError() throws {}
	
	override func tearDownWithError() throws {}
	
	func testConvert() throws {
		let expect = expectation(description: "should finish after some time")
		let converter = Converter()
		let data = Data() // not used in mock
		
		converter.convert(data, to: .obj) { progress in
			print(progress)
			switch progress {
			case .completed: expect.fulfill()
			default: break
			}
		}
		
		waitForExpectations(timeout: 10) { (error) in
			print("done")
		}
	}
}
