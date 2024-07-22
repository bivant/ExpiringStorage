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
	private(set) var lastProvidedElementIndex: Int?
	
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
		if let lastProvidedElementIndex {
			let elementsRemainder = elements[lastProvidedElementIndex + 1..<elements.count]
			if !elementsRemainder.isEmpty,
			   let firstValidIndex = elementsRemainder.firstIndex(where: isElementValid) {
				self.lastProvidedElementIndex = firstValidIndex
				return elements[firstValidIndex].0
			} else {
				elements.removeLast(elementsRemainder.count)
			}
		}
		
		if let firstValidIndex = elements.firstIndex(where: isElementValid) {
			lastProvidedElementIndex = firstValidIndex
			return elements[firstValidIndex].0
		} else {
			removeAll()
			return nil
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
			if let lastIndex = self.lastProvidedElementIndex, indexToDelete <= lastIndex {
				self.lastProvidedElementIndex = lastIndex - 1
			}
		}
	}
	
	public func removeAll() {
		elements = .init()
		lastProvidedElementIndex = nil
	}
}
