//
//  ExpiringStorageType.swift
//  
//
//  Created by Van on 19.07.2024.
//

import Foundation

public protocol ExpiringStorageType: AnyObject {
	init(expirationInterval: TimeInterval)
	associatedtype ExpiringElement
	var numberOfValidElements: Int { get }
	var nextValid: ExpiringElement? { get }
	func addNew(_: ExpiringElement)
	func clearExpired()
	func removeAll()
}

protocol ExpringStorageWithCurrentTimeType: ExpiringStorageType {
	var currentTime: Date { get }
}
