//
//  ConvertQueueTests.swift
//  Shapr3DFileConverterTests
//
//  Created by Aldrich Co on 7/14/20.
//  Copyright © 2020 Aldrich Co. All rights reserved.
//

import XCTest
@testable import Shapr3DFileConverter

class ConvertQueueTests: XCTestCase {

	func testQueueJobsShouldBeListedWhileOngoing() {
		// ... and should not be 'ongoing' when
		// finished
		
		let expect = expectation(description: "conversion request should finish")

		let queue = ConversionQueue(converter: Converter())
		
		let isOngoing = { (id: UUID) -> Bool in
			queue.ongoingConversions.contains(id)
		}
		
		let data = Data(capacity: 100)
		
		let id = UUID()
		queue.add(id: id, data: data, format: .step) { info in
		
			if info.progress < 1 {
				XCTAssertTrue(isOngoing(id))
			} else {
				XCTAssertFalse(isOngoing(id))
				expect.fulfill()
			}
		}
		
		waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error)
		}
	}
	
	func testQueueAllRequestsShouldFinish() {
		
		let expect = expectation(description: "all conversion requests should finish")
		let queue = ConversionQueue(converter: Converter())
		
		let data = Data(capacity: 100)
		
		// three requests, we want to see each them
		// would finish (they wouldn't error out)
		var requests: [UUID: ShaprOutputFormat] = [
			UUID(): .step,
			UUID(): .stl,
			UUID(): .obj,
		]
		
		requests.forEach { id, format in
			queue.add(id: id, data: data, format: format) { info in
				
				if info.progress >= 1 {
					requests.removeValue(forKey: info.id)
				}
				
				if requests.isEmpty {
					expect.fulfill()
				}
			}
		}

		waitForExpectations(timeout: 10) { error in
			XCTAssertNil(error)
		}
	}
}
