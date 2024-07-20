//
//  ExpiringStorageType.swift
//
//
//  Created by Van on 19.07.2024.
//

import Foundation

open class ExpiringStorage<T>: ExpiringStorageType {
	private let expirationInterval: TimeInterval
	typealias ElementWithDate = (T, Date)
	
	required public init(expirationInterval: TimeInterval) {
		self.expirationInterval = expirationInterval
	}
	
	private(set) var elements = [ElementWithDate]()
	private(set) var lastProvidedElementIndex: Int = -1
	
	func isElementValid(_ elementDate: ElementWithDate) -> Bool {
		currentTime.timeIntervalSince(elementDate.1) < expirationInterval
	}
	
	var currentTime: Date { Date() }
	
	func validElements() -> [T] {
		elements.compactMap({ elementDate in
			guard isElementValid(elementDate) else { return nil }
			return elementDate.0
		})
	}
	
	func addNew(element: T, date: Date) {
		clearExpired()
		elements.append((element, date))
	}

	//MARK: - ExpiringStorageType
	
	public var numberOfValidElements: Int {
		validElements().count
	}
	
	public var nextValid: T? {
		let validElements = validElements()
		if lastProvidedElementIndex >= 0 {
			if validElements.isEmpty {
				removeAll()
				return nil
			}
			lastProvidedElementIndex += 1

			let numberOfValidElements = validElements.count
			if lastProvidedElementIndex >= numberOfValidElements {
				lastProvidedElementIndex = 0
			}
			return validElements[lastProvidedElementIndex]
		} else {
			if !validElements.isEmpty {
				lastProvidedElementIndex = 0
			} else {
				removeAll()
			}
			return validElements.first
		}
	}
	
	public func addNew(_ element: T) {
		addNew(element: element, date: Date())
	}
	
	public func clearExpired() {
		var indexesToRemove = [Int]()
//        var correctedlastProvidedElementIndex = lastProvidedElementIndex
		elements.enumerated().forEach { index, elementDate in
			if !isElementValid(elementDate) {
				indexesToRemove.append(index)
			}
		}
		indexesToRemove.reversed().forEach { indexToDelete in
			elements.remove(at: indexToDelete)
			if indexToDelete <= lastProvidedElementIndex {
				lastProvidedElementIndex -= 1
			}
		}
	}
	
	public func removeAll() {
		elements = .init()
		lastProvidedElementIndex = -1
	}
}

extension ExpiringStorage: ExpringStorageWithCurrentTimeType {
}
