//
//  ExpiringStorageWithFixedCurrentTime.swift
//
//
//  Created by Van on 19.07.2024.
//

import Foundation
@testable import ExpiringStorage

final class ExpiringStorageWithFixedCurrentTime: ExpiringStorage<Int> {
	var fixedTime: Date
	
	init(expirationInterval: TimeInterval, currentTime: Date) {
		self.fixedTime = currentTime
		super.init(expirationInterval: expirationInterval)
	}
	
	required init(expirationInterval: TimeInterval) {
		fixedTime = Date()
		super.init(expirationInterval: expirationInterval)
	}
	
	override var currentTime: Date { fixedTime }
	
	func addNew(_ element: Int, withOffset offset: TimeInterval) {
		addNew(element: element, date: fixedTime.addingTimeInterval(offset))
	}
}
