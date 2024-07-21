import XCTest
@testable import ExpiringStorage

final class ExpiringStoragePublicTests: XCTestCase {
	var storage: ExpiringStorageWithFixedCurrentTime!
	
	override func setUp() {
		storage = ExpiringStorageWithFixedCurrentTime(expirationInterval: 10)
	}
	
	private func printStorage() {
		// XCTest Documentation
		// https://developer.apple.com/documentation/xctest
		
		// Defining Test Cases and Test Methods
		// https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
		print("Storage elements \(storage.elements.map{ $0.0 })")
	}
	
	func test_numberOfValidElements() {
		(0..<12).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertEqual(storage.numberOfValidElements, 10)
	}
	
	func test_numberOfValidElements_afterCurrentTimeChange() {
		(0..<12).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		XCTAssertEqual(storage.numberOfValidElements, 5)
	}
	
	//MARK: - nextValid
	func test_nextValid_nilForEmpty() {
		XCTAssertNil(storage.nextValid)
	}
	
	func test_nextValid_nilForExpired() {
		(10..<12).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertNil(storage.nextValid)
	}

	func test_nextValid_1Of1Valid() {
		storage.addNew(0, withOffset: 0)
		XCTAssertEqual(storage.nextValid, 0)
	}
	
	func test_nextValid_sameFor1Of1Valid() {
		storage.addNew(0, withOffset: 0)
		XCTAssertEqual(storage.nextValid, 0)
		XCTAssertEqual(storage.nextValid, 0)
		XCTAssertEqual(storage.nextValid, 0)
	}
	
	func test_nextValid_1For1Of2Valid() {
		(0..<2).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertEqual(storage.nextValid, 0)
	}

	func test_nextValid_2For2Of2Valid() {
		(0..<2).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 1)
	}
	
	func test_nextValid_1For3Of2Valid() {
		(0..<2).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		_ = storage.nextValid
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 0)
	}
	
	func test_nextValid_mixedValidInvalid() {
		zip(0..<5, 5..<10).reduce([Int]()) { arrayResult, pair in
			let (lesser, bigger) = pair
			return arrayResult + [lesser, bigger]
		}.forEach { storage.addNew($0, withOffset: TimeInterval(-$0)); print($0) }
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		_ = storage.nextValid
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 2)
	}
	
	func test_newValid_afterClearExpired() {
		zip(0..<5, 5..<10).reduce([Int]()) { arrayResult, pair in
			let (lesser, bigger) = pair
			return arrayResult + [lesser, bigger]
		}.forEach { storage.addNew($0, withOffset: TimeInterval(-$0)); print($0) }
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		_ = storage.nextValid
		_ = storage.nextValid
		_ = storage.nextValid
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, 3)
	}
	
	func test_newValid_nilAfterClearExpired() {
		zip(0..<5, 5..<10).reduce([Int]()) { arrayResult, pair in
			let (lesser, bigger) = pair
			return arrayResult + [lesser, bigger]
		}.forEach { storage.addNew($0, withOffset: TimeInterval(-$0)); print($0) }
		storage.fixedTime = storage.fixedTime.addingTimeInterval(10)
		_ = storage.nextValid
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, nil)
	}
	
	func test_newValid_afterClearExpiredOverEdge() {
		zip(0..<3, 5..<10).reduce([Int]()) { arrayResult, pair in
			let (lesser, bigger) = pair
			return arrayResult + [lesser, bigger]
		}.forEach { storage.addNew($0, withOffset: TimeInterval(-$0)); print($0) }
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 1)
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, 2)
		XCTAssertEqual(storage.nextValid, 0)
		XCTAssertEqual(storage.nextValid, 1)
	}
	
	func test_newValid_afterClearExpiredWithNextExpired() {
		zip(0..<4, 5..<10).reduce([Int]()) { arrayResult, pair in
			let (lesser, bigger) = pair
			return arrayResult + [lesser, bigger]
		}.forEach { storage.addNew($0, withOffset: TimeInterval(-$0)); print($0) }
		_ = storage.nextValid
		_ = storage.nextValid
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 6)
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, 2)
		XCTAssertEqual(storage.nextValid, 3)
		XCTAssertEqual(storage.nextValid, 0)
	}
	
	func test_newValid_nextExpiredWithDelayedClear() {
		zip(0..<4, 5..<10).reduce([Int]()) { arrayResult, pair in
			let (lesser, bigger) = pair
			return arrayResult + [lesser, bigger]
		}.forEach { storage.addNew($0, withOffset: TimeInterval(-$0)); print($0) }
		_ = storage.nextValid
		_ = storage.nextValid
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 6)
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		XCTAssertEqual(storage.nextValid, 2)
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, 3)
		XCTAssertEqual(storage.nextValid, 0)
	}
	
	func test_newValid_clearExpired_nextExpiredUntilEdgeWithDelayedClear() {
		(3..<10).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		_ = storage.nextValid
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 5)
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, 3)
		XCTAssertEqual(storage.nextValid, 4)
		XCTAssertEqual(storage.nextValid, 3)
	}
	
	func test_newValid_clearExpired_nextExpiredLastElementWithDelayedClear() {
		(3..<10).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		storage.addNew(0, withOffset: TimeInterval(0))
		_ = storage.nextValid
		_ = storage.nextValid
		XCTAssertEqual(storage.nextValid, 5)
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		storage.clearExpired()
		XCTAssertEqual(storage.nextValid, 0)
		XCTAssertEqual(storage.nextValid, 3)
		XCTAssertEqual(storage.nextValid, 4)
		XCTAssertEqual(storage.nextValid, 0)
	}
	
	//MARK: - addNew
	func test_addNew_addsElement() {
		XCTAssertTrue(storage.elements.isEmpty)
		storage.addNew(0, withOffset: 0)
		XCTAssertEqual(storage.elements.count, 1)
		storage.addNew(0, withOffset: 3)
		XCTAssertEqual(storage.elements.count, 2)
	}
	
	func test_addNew_removesExistingExpired() {
		XCTAssertTrue(storage.elements.isEmpty)
		(8..<10).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertEqual(storage.elements.count, 2)
		storage.addNew(10, withOffset: -10)
		XCTAssertEqual(storage.elements.count, 3)
		storage.addNew(11, withOffset: -11)
		XCTAssertEqual(storage.elements.count, 3)
	}
	
	func test_clearExpired_afterCurrentTimeChange() {
		(0..<10).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertEqual(storage.elements.count, 10)
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		storage.clearExpired()
		XCTAssertEqual(storage.elements.count, 5)
//		print("storage elements \(storage.elements.map{ $0.0 })")
	}
	
	func test_clearExpired_afterCurrentTimeChange_inverted() {
		(0..<10).reversed().forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertEqual(storage.elements.count, 10)
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		storage.clearExpired()
		XCTAssertEqual(storage.elements.count, 5)
	}
	
	func test_removeAll() {
		(0..<5).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertFalse(storage.elements.isEmpty)
		storage.removeAll()
		XCTAssertTrue(storage.elements.isEmpty)
	}
}
