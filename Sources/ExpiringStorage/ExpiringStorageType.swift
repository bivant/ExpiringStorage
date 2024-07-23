//
//  ExpiringStorageType.swift
//  
//
//  Created by Van on 19.07.2024.
//

import Foundation

public protocol ExpiringStorageType: ExpiringStorageTypeReading, ExpiringStorageTypeMutating {
	init(expirationInterval: TimeInterval)
}

public protocol ExpiringStorageTypeReading {
	associatedtype ExpiringElement
	var numberOfValidElements: Int { get }
	var allValid: any Collection<ExpiringElement> { get }
}

public protocol ExpiringStorageTypeMutating {
	associatedtype ExpiringElement
	var nextValid: ExpiringElement? { get }
	mutating func addNew(_: ExpiringElement)
	mutating func clearExpired()
	mutating func removeAll()
}
