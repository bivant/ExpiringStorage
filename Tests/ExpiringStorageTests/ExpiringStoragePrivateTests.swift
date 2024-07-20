import XCTest
@testable import ExpiringStorage

final class ExpiringStoragePrivateTests: XCTestCase {

	var storage: ExpiringStorageWithFixedCurrentTime!
	
	override func setUp() {
		storage = ExpiringStorageWithFixedCurrentTime(expirationInterval: 10)
	}
		
	func test_isElementValid() {
		let validDate = storage.fixedTime.addingTimeInterval(-5)
		XCTAssertTrue(storage.isElementValid((0, validDate)))
		let invalidEdgeDate = storage.fixedTime.addingTimeInterval(-10)
		XCTAssertFalse(storage.isElementValid((0, invalidEdgeDate)))
		let invalidPastDate = storage.fixedTime.addingTimeInterval(-15)
		XCTAssertFalse(storage.isElementValid((0, invalidPastDate)))
	}
	
	func test_validElements() {
		(0..<12).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		XCTAssertEqual(storage.validElements(), Array(0..<10))
	}
	
	func test_validElements_afterCurrentTimeChange() {
		(0..<12).forEach { storage.addNew($0, withOffset: TimeInterval(-$0)) }
		storage.fixedTime = storage.fixedTime.addingTimeInterval(5)
		XCTAssertEqual(storage.validElements(), Array(0..<5))
	}
}
